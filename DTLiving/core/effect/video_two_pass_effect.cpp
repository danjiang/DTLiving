//
//  video_two_pass_effect.cpp
//  DTLiving
//
//  Created by Dan Jiang on 2020/4/15.
//  Copyright © 2020 Dan Thought Studio. All rights reserved.
//

#include "video_two_pass_effect.h"
#include "video_texture_cache.h"

namespace dtliving {
namespace effect {

VideoTwoPassEffect::VideoTwoPassEffect(std::string name)
: VideoEffect(name) {
}

void VideoTwoPassEffect::LoadShaderSource2(std::string vertex_shader_source1, std::string fragment_shader_source1,
                                          std::string vertex_shader_source2, std::string fragment_shader_source2) {
    LoadShaderSource(vertex_shader_source1, fragment_shader_source1);
    
    program2_ = new ShaderProgram();
    program2_->CompileSource(vertex_shader_source2.c_str(), fragment_shader_source2.c_str());
}

void VideoTwoPassEffect::LoadUniform() {
    VideoEffect::LoadUniform();
    
    a_position2_ = program2_->AttributeLocation("a_position");
    a_texcoord2_ = program2_->AttributeLocation("a_texcoord");
    u_texture2_ = program2_->UniformLocation("u_texture");
}

void VideoTwoPassEffect::Render(VideoFrame input_frame, VideoFrame output_frame, GLfloat *positions, GLfloat *texture_coordinates) {
    // first pass
    
    glBindTexture(GL_TEXTURE_2D, input_frame.texture_name);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    auto texture = VideoTextureCache::GetInstance()->FetchTexture(input_frame.width,
                                                                  input_frame.height);
    texture->Lock();

    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture->get_texture_name(), 0);

    program_->Use();
        
    BeforeDrawArrays(output_frame.height, output_frame.width, 0);
    
    glClearColor(clear_color_red_, clear_color_green_, clear_color_blue_, clear_color_alpha_);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, input_frame.texture_name);
    glUniform1i(u_texture_, 0);
    
    glEnableVertexAttribArray(a_position_);
    glVertexAttribPointer(a_position_,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          0,
                          positions);
    
    glEnableVertexAttribArray(a_texcoord_);
    glVertexAttribPointer(a_texcoord_,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          0,
                          texture_coordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // second pass
    
    glBindTexture(GL_TEXTURE_2D, texture->get_texture_name());
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, output_frame.texture_name, 0);

    program2_->Use();
        
    BeforeDrawArrays(output_frame.height, output_frame.width, 1);
    
    glClearColor(clear_color_red_, clear_color_green_, clear_color_blue_, clear_color_alpha_);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture->get_texture_name());
    glUniform1i(u_texture2_, 0);
    
    glEnableVertexAttribArray(a_position2_);
    glVertexAttribPointer(a_position2_,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          0,
                          positions);
    
    glEnableVertexAttribArray(a_texcoord2_);
    glVertexAttribPointer(a_texcoord2_,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          0,
                          texture_coordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    texture->UnLock();
}

}
}
