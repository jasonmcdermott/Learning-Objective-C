- (void)renderRing
{
    if (shapeType == 0) {
        [self drawGradient withOpaqueSize:diameter-blur withTransparentSize:0 withOpacity:Alpha withBlur:0 withNumSides:numSides];
        [self drawGradient withOpaqueSize:diameter withTransparentSize:diameter-blur withOpacity:0 withBlur:0 withNumSides:numSides];
    } else if (shapeType == 1) {
        [self drawGradient withOpaqueSize:diameter+thickness-blur withTransparentSize:diameter-thickness+blur withOpacity:Alpha withBlur:0 withNumSides:numSides];
        [self drawGradient withOpaqueSize:diameter+thickness withTransparentSize:diameter+thickness-blur withOpacity:0 withBlur:0 withNumSides:numSides];
        [self drawGradient withOpaqueSize:diameter-thickness withTransparentSize:diameter-thickness+blur withOpacity:0 withBlur:0 withNumSides:numSides];
    } else if (shapeType == 2) {
        [self drawGradient withOpaqueSize:diameter-thickness withTransparentSize:diameter+thickness withOpacity:0 withBlur:0 withNumSides:numSides];
        [self drawGradient withOpaqueSize:diameter+thickness+thickness*0.07 withTransparentSize:diameter+thickness withOpacity:0 withBlur:0 withNumSides:numSides];
    }
}

- (void)drawGradient
withOpaqueSize:(NSInteger)opaqueSize
withTransparentSize(NSInteger)transparentSize
withOpacity:(NSInteger)opacity
withBlur:(NSInteger)blur withNumSides(NSInteger)numSides
{
    
//    GLfloat* ver_coords = new GLfloat[ (ns+1) * 4];
//    GLfloat* ver_cols = new GLfloat[ (ns+1) * 8];
    
    GLfloat ver_coords[];
    GLfloat ver_cols[];
    
    float angle;
    float angleSize =  2 * PI / numSides;
    
    if (opaqueSize < transparentSize) {
        middleradius = opaqueSize - ((transparentSize-opaqueSize)+blur);
    } else {
        middleradius = opaque - ((transp-opaque)+blur_);
    }
    
    middleradius = (opaqueSize + transparentSize)/2;
    
    for (int i=0; i< (1+ns); i++) {
        angle = i* angleSize;
        ver_coords[i*4+0] = (opaqueSize * cos(angle));
        ver_coords[i*4+1] = (opaqueSize * sin(angle));
        ver_cols[i*8+0] = Red;
        ver_cols[i*8+1] = Green;
        ver_cols[i*8+2] = Blue;
        ver_cols[i*8+3] = opac_;
        ver_coords[i*4+2] = (transparentSize * cos(angle));
        ver_coords[i*4+3] = (transparentSize * sin(angle));
        ver_cols[i*8+4] = Red;
        ver_cols[i*8+5] = Green;
        ver_cols[i*8+6] = Blue;
        ver_cols[i*8+7] = Alpha;
    }
    
    glVertexPointer( 2, GL_FLOAT, 0, ver_coords);
    glColorPointer(4, GL_FLOAT, 0, ver_cols);
    glDrawArrays( GL_TRIANGLE_STRIP, 0, ( numSides + 1 ) * 2 );
    
//    delete[] ver_coords;
//    delete[] ver_cols;

}
