//
//  VideoView.swift
//  DTLiving
//
//  Created by Dan Jiang on 2020/3/5.
//  Copyright © 2020 Dan Thought Studio. All rights reserved.
//

import UIKit
import GLKit
import AVFoundation
import CocoaLumberjack

class VideoView: UIView, VideoInput {
    
    enum FillMode {
        // Stretch to fill the full view, which may distort the image outside of its normal aspect ratio
        case stretch
        // Maintains the aspect ratio of the source image, adding bars of the specified background color
        case aspectFit
        // Maintains the aspect ratio of the source image, zooming in on its center to fill the view
        case aspectFill
    }
    
    var fillMode: FillMode = .aspectFit
    var backgroundColorRed: CGFloat = 0.0
    var backgroundColorGreen: CGFloat = 0.0
    var backgroundColorBlue: CGFloat = 0.0
    var backgroundColorAlpha: CGFloat = 1.0

    private var inputFrameBuffer: FrameBuffer?
    private var inputRotation: VideoRotation = .noRotation {
        didSet {
            if inputRotation != oldValue {
                textureVertices = textureCoordinates(for: inputRotation)
            }
        }
    }
    private var inputSize: CGSize = .zero

    private var program: ShaderProgramObject?
    private var positionSlot = GLuint()
    private var texturePositionSlot = GLuint()
    private var textureUniform = GLint()
    private var squareVertices: [GLfloat] = [
        -1, -1,
        1, -1,
        -1, 1,
        1, 1
    ]
    private var textureVertices: [GLfloat] = [
        0, 1,
        1, 1,
        0, 0,
        1, 0
    ]

    private var displayRenderBuffer: GLuint = 0
    private var displayFrameBuffer: GLuint = 0
    private var outputSize: CGSize = .zero

    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }

    private var eaglLayer: CAEAGLLayer? {
        return layer as? CAEAGLLayer
    }
    
    deinit {
        VideoContext.sharedProcessingContext.sync {
            destroyDisplayFrameBuffer()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentScaleFactor = UIScreen.main.scale
        
        guard let eaglLayer = eaglLayer else { return }
        eaglLayer.isOpaque = true
        eaglLayer.drawableProperties = [kEAGLDrawablePropertyRetainedBacking: false,
                                        kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8]

        VideoContext.sharedProcessingContext.sync {
            VideoContext.sharedProcessingContext.useAsCurrentContext()
            
            createShaderProgram()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.size != .zero {
            if bounds.size != outputSize {
                VideoContext.sharedProcessingContext.sync {
                    destroyDisplayFrameBuffer()
                    createDisplayFrameBuffer()
                }
            }
        }
    }
    
    var nextAvailableTextureIndex: Int {
        return 0
    }
    
    var enabled: Bool {
        return true
    }
    
    func setInputFrameBuffer(_ inputFrameBuffer: FrameBuffer?, at index: Int) {
        self.inputFrameBuffer = inputFrameBuffer
        inputFrameBuffer?.lock()
    }
        
    func setInputRotation(_ rotation: VideoRotation, at index: Int) {
        inputRotation = rotation
    }
    
    func setInputSize(_ size: CGSize, at index: Int) {
        VideoContext.sharedProcessingContext.sync {
            var rotatedSize = size
            if VideoRotationNeedSwapWidthAndHeight(inputRotation) {
                rotatedSize.width = size.height
                rotatedSize.height = size.width
            }
            if inputSize != rotatedSize {
                inputSize = rotatedSize
                recalculateViewGeometry()
            }
        }        
    }
    
    func newFrameReady(at time: CMTime, at index: Int) {
        guard let inputFrameBuffer = inputFrameBuffer else { return }
        
        VideoContext.sharedProcessingContext.sync {
            VideoContext.sharedProcessingContext.setShaderProgram(program)
            setDisplayFrameBuffer()
            
            glClearColor(GLclampf(backgroundColorRed),
                         GLclampf(backgroundColorGreen),
                         GLclampf(backgroundColorBlue),
                         GLclampf(backgroundColorAlpha))
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
            
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), inputFrameBuffer.textureName)
            glUniform1i(textureUniform, 0)
            
            glEnableVertexAttribArray(positionSlot)
            glVertexAttribPointer(positionSlot,
                                  2,
                                  GLenum(GL_FLOAT),
                                  GLboolean(UInt8(GL_FALSE)),
                                  GLsizei(0),
                                  &squareVertices)
            
            glEnableVertexAttribArray(texturePositionSlot)
            glVertexAttribPointer(texturePositionSlot,
                                  2,
                                  GLenum(GL_FLOAT),
                                  GLboolean(UInt8(GL_FALSE)),
                                  GLsizei(0),
                                  &textureVertices)
            
            glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
            
            presentDisplayFrameBuffer()
            
            self.inputFrameBuffer?.unlock()
            self.inputFrameBuffer = nil
        }
    }
    
    func endProcessing() {}
    
    private func createShaderProgram() {
        VideoContext.sharedProcessingContext.sync {
            let program = ShaderProgramObject(vertexShader: "effect_vertex", fragmentShader: "effect_fragment")
            positionSlot = program.attributeLocation("a_position")
            texturePositionSlot = program.attributeLocation("a_texcoord")
            textureUniform = program.uniformLocation("u_texture")
            self.program = program
        }
    }
    
    private func createDisplayFrameBuffer() {
        VideoContext.sharedProcessingContext.useAsCurrentContext()

        glGenFramebuffers(1, &displayFrameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), displayFrameBuffer)
        
        glGenRenderbuffers(1, &displayRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), displayRenderBuffer)
        
        if !VideoContext.sharedProcessingContext.context
            .renderbufferStorage(Int(GL_RENDERBUFFER), from: eaglLayer) {
            DDLogError("Could not bind a drawable object’s storage to a render buffer object")
            exit(1)
        }
        
        var backingWidth: GLint = 0
        var backingHeight: GLint = 0
        
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_WIDTH), &backingWidth)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_HEIGHT), &backingHeight)
        
        if backingWidth == 0 || backingHeight == 0 {
            destroyDisplayFrameBuffer()
            return
        }
        
        outputSize.width = CGFloat(backingWidth)
        outputSize.height = CGFloat(backingHeight)
        
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER),
                                  GLenum(GL_COLOR_ATTACHMENT0),
                                  GLenum(GL_RENDERBUFFER),
                                  displayRenderBuffer)
        
        if glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) != GL_FRAMEBUFFER_COMPLETE {
            DDLogError("[VideoView] Could not generate frame buffer")
            exit(1)
        }
                
        recalculateViewGeometry()
    }
    
    private func destroyDisplayFrameBuffer() {
        VideoContext.sharedProcessingContext.useAsCurrentContext()
        
        if displayFrameBuffer != 0 {
            glDeleteFramebuffers(1, &displayFrameBuffer)
            displayFrameBuffer = 0
        }
        
        if displayRenderBuffer != 0 {
            glDeleteRenderbuffers(1, &displayRenderBuffer)
            displayRenderBuffer = 0
        }
    }
    
    private func setDisplayFrameBuffer() {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), displayFrameBuffer)
        glViewport(0, 0, GLsizei(outputSize.width), GLsizei(outputSize.height))
    }
    
    private func presentDisplayFrameBuffer() {
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), displayRenderBuffer)
        VideoContext.sharedProcessingContext.presentBufferForDisplay()
    }
    
    private func recalculateViewGeometry() {
        VideoContext.sharedProcessingContext.sync {
            var widthScaling: GLfloat = 0
            var heightScaling: GLfloat = 0
                        
            let insetRect = AVMakeRect(aspectRatio: inputSize,
                                       insideRect: .init(x: 0, y: 0,
                                                         width: outputSize.width,
                                                         height: outputSize.height))
            
            switch fillMode {
            case .stretch:
                widthScaling = 1.0
                heightScaling = 1.0
            case .aspectFit:
                widthScaling = GLfloat(insetRect.size.width / outputSize.width)
                heightScaling = GLfloat(insetRect.size.height / outputSize.height)
            case .aspectFill:
                widthScaling = GLfloat(outputSize.height / insetRect.size.height)
                heightScaling = GLfloat(outputSize.width / insetRect.size.width)
            }
            
            squareVertices[0] = -widthScaling
            squareVertices[1] = -heightScaling
            squareVertices[2] = widthScaling
            squareVertices[3] = -heightScaling
            squareVertices[4] = -widthScaling
            squareVertices[5] = heightScaling
            squareVertices[6] = widthScaling
            squareVertices[7] = heightScaling
        }
    }
    
    private func textureCoordinates(for rotation: VideoRotation) -> [GLfloat] {
        // vertical flip
        switch rotation {
        case .noRotation:
            return [0, 1,
                    1, 1,
                    0, 0,
                    1, 0]
        case .rotateLeft:
            return [0, 0,
                    0, 1,
                    1, 0,
                    1, 1]
        case .rotateRight:
            return [1, 1,
                    1, 0,
                    0, 1,
                    0, 0]
        case .flipVertical:
            return [0, 0,
                    1, 0,
                    0, 1,
                    1, 1]
        case .flipHorizonal:
            return [1, 1,
                    0, 1,
                    1, 0,
                    0, 0]
        case .rotateRightFlipVertical:
            return [1, 0,
                    1, 1,
                    0, 0,
                    0, 1]
        case .rotateRightFlipHorizontal:
            return [0, 1,
                    0, 0,
                    1, 1,
                    1, 0]
        case .rotate180:
            return [1, 0,
                    0, 0,
                    1, 1,
                    0, 1]
        default:
            return [0, 1,
                    1, 1,
                    0, 0,
                    1, 0]
        }
    }

}
