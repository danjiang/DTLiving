//
//  video_effect.h
//  DTLiving
//
//  Created by Dan Jiang on 2020/3/12.
//  Copyright © 2020 Dan Thought Studio. All rights reserved.
//

#ifndef DTLIVING_EFFECT_VIDEO_EFFECT_H_
#define DTLIVING_EFFECT_VIDEO_EFFECT_H_

#include <map>

#include "shader_program.h"
#include "video_frame.h"
#include "video_effect_uniform.h"
#include "png_decoder.h"

namespace dtliving {
namespace effect {

class VideoEffect {    
public:
    static std::string VertexShader();
    static std::string FragmentShader();
    static std::string GrayScaleFragmentShader();
    static std::vector<GLfloat> CaculateOrthographicMatrix(GLfloat width, GLfloat height,
                                                           bool ignore_aspect_ratio = false);

    VideoEffect(std::string name);
    ~VideoEffect();
    
    void LoadShaderFile(std::string vertex_shader_file, std::string fragment_shader_file);
    virtual void LoadShaderSource();
    virtual void LoadUniform();
    virtual void LoadResources(std::vector<std::string> resources);
    
    void SetPositions(std::vector<GLfloat> positions);
    void SetTextureCoordinates(std::vector<GLfloat> texture_coordinates);
    void SetUniform(std::string name, VideoEffectUniform uniform);
    
    void Render(VideoFrame input_frame, VideoFrame output_frame);
    virtual void Render(VideoFrame input_frame, VideoFrame output_frame, std::vector<GLfloat> positions, std::vector<GLfloat> texture_coordinates);

    std::string get_name() { return name_; }
    void set_clear_color(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) { // TODO: Rewrite
        clear_color_red_ = red;
        clear_color_green_ = green;
        clear_color_blue_ = blue;
        clear_color_alpha_ = alpha;
    }
    void get_clear_color(GLfloat *clear_color) {
        *clear_color = clear_color_red_;
        *(clear_color + 1) = clear_color_green_;
        *(clear_color + 2) = clear_color_blue_;
        *(clear_color + 3) = clear_color_alpha_;
    }
    
protected:
    void LoadShaderSource(std::string vertex_shader_source, std::string fragment_shader_source);
    virtual void BeforeSetPositions(GLsizei width, GLsizei height, int program_index);
    virtual void BeforeDrawArrays(GLsizei width, GLsizei height, int program_index);
    
    GLfloat clear_color_red_;
    GLfloat clear_color_green_;
    GLfloat clear_color_blue_;
    GLfloat clear_color_alpha_;

    ShaderProgram *program_;
    GLuint a_position_;
    GLuint a_texcoord_;
    GLint u_texture_;
    std::vector<GLfloat> positions_;
    std::vector<GLfloat> texture_coordinates_;

    std::map<std::string, VideoEffectUniform> uniforms_;
    
    decoder::image::PngDecoder *png_decoder_;

private:
    std::string name_;
};

}
}

#endif /* video_effect_h */
