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

#include "png_decoder.h"
#include "vector.h"
#include "shader_program.h"
#include "video_frame.h"
#include "video_effect_uniform.h"

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
    
    virtual void LoadShaderFile(std::string vertex_shader_file, std::string fragment_shader_file);
    virtual void LoadShaderSource();
    virtual void LoadUniform();
    virtual void LoadResources(std::vector<std::string> resources);
    virtual void SetTextures(std::vector<VideoFrame> textures);

    void SetPositions(std::vector<GLfloat> positions);
    void SetTextureCoordinates(std::vector<GLfloat> texture_coordinates);
    void SetUniform(std::string name, VideoEffectUniform uniform);    
    
    bool Update(double delta, GLsizei width, GLsizei height);
    void Render(VideoFrame input_frame, VideoFrame output_frame);

    std::string get_name() { return name_; }
    void set_duration(double duration) {
        duration_ = duration;
    }
    double get_duration() {
        return duration_;
    }
    void set_clear_color(vec4 clear_color) {
        clear_color_ = clear_color;
    }
    vec4 get_clear_color() {
        return clear_color_;
    }
    
protected:
    void LoadShaderSource(std::string vertex_shader_source, std::string fragment_shader_source);
    
    virtual void Update(GLsizei width, GLsizei height);
    virtual void Render(VideoFrame input_frame, VideoFrame output_frame, std::vector<GLfloat> positions, std::vector<GLfloat> texture_coordinates);

    virtual void BeforeSetPositions(GLsizei width, GLsizei height, int program_index);
    virtual void BeforeDrawArrays(GLsizei width, GLsizei height, int program_index);
    
    ShaderProgram *program_;
    GLuint a_position_;
    GLuint a_texcoord_;
    GLint u_texture_;
    std::vector<GLfloat> positions_;
    std::vector<GLfloat> texture_coordinates_;

    std::map<std::string, VideoEffectUniform> uniforms_;
    
    decoder::image::PngDecoder *png_decoder_;

    double time_since_first_update_ = 0;

private:
    std::string name_;
    double duration_ = -1; // negative mean infinite
    vec4 clear_color_;
};

}
}

#endif /* video_effect_h */
