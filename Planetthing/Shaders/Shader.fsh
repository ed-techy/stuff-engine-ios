//
//  Shader.fsh
//  Planetthing
//
//  Created by Omar De Anda on 7/8/15.
//  Copyright (c) 2015 Hotwasser Games. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
