//
//  video_texture.h
//  DTLiving
//
//  Created by Dan Jiang on 2020/3/18.
//  Copyright © 2020 Dan Thought Studio. All rights reserved.
//

#ifndef DTLIVING_OPENGL_VIDEO_TEXTURE_H_
#define DTLIVING_OPENGL_VIDEO_TEXTURE_H_

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

namespace dtliving {
namespace opengl {

class VideoTexture {
public:
    VideoTexture(GLsizei width, GLsizei height);
    ~VideoTexture();
private:
    GLsizei width;
    GLsizei height;
    GLuint textureName;
};

}
}

#endif /* video_texture_h */
