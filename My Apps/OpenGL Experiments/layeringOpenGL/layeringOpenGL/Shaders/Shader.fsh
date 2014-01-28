//
//  Shader.fsh
//  layeringOpenGL
//
//  Created by Jason McDermott on 28/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
