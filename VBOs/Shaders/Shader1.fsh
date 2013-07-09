//
//  Shader.fsh
//  VBOs
//
//  Created by takayuki-a on 2013/07/09.
//  Copyright (c) 2013年 Takayuki Akaguma. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
