//
//  video_levels_effect.cpp
//  DTLiving
//
//  Created by Dan Jiang on 2020/4/8.
//  Copyright © 2020 Dan Thought Studio. All rights reserved.
//

#include "constants.h"
#include "video_levels_effect.h"

namespace dtliving {
namespace effect {
namespace color_processing {

VideoLevelsEffect::VideoLevelsEffect(const char *name, const char *vertex_shader_file, const char *fragment_shader_file)
: VideoEffect(name, vertex_shader_file, fragment_shader_file) {
}

void VideoLevelsEffect::BeforeDrawArrays() {
    GLint location = program_->UniformLocation(kVideoLevelsEffectLevelMaximum);
    auto uniform = uniforms_[std::string(kVideoLevelsEffectLevelMaximum)];
    glUniform3fv(location, 1, uniform.u_float);
    
    location = program_->UniformLocation(kVideoLevelsEffectLevelMiddle);
    uniform = uniforms_[std::string(kVideoLevelsEffectLevelMiddle)];
    glUniform3fv(location, 1, uniform.u_float);
    
    location = program_->UniformLocation(kVideoLevelsEffectLevelMinimum);
    uniform = uniforms_[std::string(kVideoLevelsEffectLevelMinimum)];
    glUniform3fv(location, 1, uniform.u_float);
    
    location = program_->UniformLocation(kVideoLevelsEffectMaxOutput);
    uniform = uniforms_[std::string(kVideoLevelsEffectMaxOutput)];
    glUniform3fv(location, 1, uniform.u_float);
    
    location = program_->UniformLocation(kVideoLevelsEffectMinOutput);
    uniform = uniforms_[std::string(kVideoLevelsEffectMinOutput)];
    glUniform3fv(location, 1, uniform.u_float);
}

}
}
}
