//
//  GLViewController.m
//  VBOs
//
//  Created by takayuki-a on 2013/07/09.
//  Copyright (c) 2013年 Takayuki Akaguma. All rights reserved.
//

#import "GLViewController.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

enum {
    SHADER_0,
    SHADER_1,
    
    NUM_SHADER
};

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_SHADER][NUM_UNIFORMS];


// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};



GLfloat gCubeVertexData[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};


@interface GLViewController () {
    GLuint _program[2];
    
    GLKMatrix4 _modelViewProjectionMatrix[2];
    GLKMatrix3 _normalMatrix[2];
    float _rotation;
    
    GLuint _vertexArray[2];
    GLuint _vertexBuffer[2];
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders0;
- (BOOL)loadShaders1;

- (void)bindCube0;
- (void)bindCube1;

- (void)updateCube0WithbaseModelViewMatrix:(GLKMatrix4) baseModelViewMatrix projectionMatrix:(GLKMatrix4)projectionMatrix;
- (void)updateCube1WithbaseModelViewMatrix:(GLKMatrix4) baseModelViewMatrix projectionMatrix:(GLKMatrix4)projectionMatrix;

- (void)drawCube0;
- (void)drawCube1;

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation GLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)bindCube0
{
    glGenVertexArraysOES(1, &_vertexArray[SHADER_0]);
    glBindVertexArrayOES(_vertexArray[SHADER_0]);
    
    glGenBuffers(1, &_vertexBuffer[SHADER_0]);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer[SHADER_0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);
}

- (void)bindCube1
{
    glGenVertexArraysOES(1, &_vertexArray[SHADER_1]);
    glBindVertexArrayOES(_vertexArray[SHADER_1]);
    
    glGenBuffers(1, &_vertexBuffer[SHADER_1]);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer[SHADER_1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders0];
    [self loadShaders1];
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    glEnable(GL_DEPTH_TEST);
    
    [self bindCube0];
    [self bindCube1];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer[SHADER_0]);
    glDeleteVertexArraysOES(1, &_vertexArray[SHADER_0]);
    glDeleteBuffers(1, &_vertexBuffer[SHADER_1]);
    glDeleteVertexArraysOES(1, &_vertexArray[SHADER_1]);
    
    self.effect = nil;
    
    if (_program[SHADER_0]) {
        glDeleteProgram(_program[SHADER_0]);
        _program[SHADER_0] = 0;
    }
    if (_program[SHADER_1]) {
        glDeleteProgram(_program[SHADER_1]);
        _program[SHADER_1] = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)updateCube0WithbaseModelViewMatrix:(GLKMatrix4) baseModelViewMatrix projectionMatrix:(GLKMatrix4)projectionMatrix
{
    GLKMatrix4 modelViewMatrix;
    
    // Compute cube0 matrix
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    _normalMatrix[SHADER_0] = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    _modelViewProjectionMatrix[SHADER_0] = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
}

- (void)updateCube1WithbaseModelViewMatrix:(GLKMatrix4) baseModelViewMatrix projectionMatrix:(GLKMatrix4)projectionMatrix
{
    GLKMatrix4 modelViewMatrix;
    
    // Compute cube1 matrix
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    _normalMatrix[SHADER_1] = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    _modelViewProjectionMatrix[SHADER_1] = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
}


- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    
    [self updateCube0WithbaseModelViewMatrix:baseModelViewMatrix projectionMatrix:projectionMatrix];
    [self updateCube1WithbaseModelViewMatrix:baseModelViewMatrix projectionMatrix:projectionMatrix];
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
}

- (void)drawCube0
{
    glBindVertexArrayOES(_vertexArray[SHADER_0]);
    
    // Render the object again with ES2
    glUseProgram(_program[SHADER_0]);
    
    glUniformMatrix4fv(uniforms[SHADER_0][UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix[SHADER_0].m);
    glUniformMatrix3fv(uniforms[SHADER_0][UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix[SHADER_0].m);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArrayOES(0);    
}

- (void)drawCube1
{
    glBindVertexArrayOES(_vertexArray[SHADER_1]);
    
    // Render the object again with ES2
    glUseProgram(_program[SHADER_1]);
    
    glUniformMatrix4fv(uniforms[SHADER_1][UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix[SHADER_1].m);
    glUniformMatrix3fv(uniforms[SHADER_1][UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix[SHADER_1].m);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArrayOES(0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self drawCube0];
    [self drawCube1];
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders0
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program[SHADER_0] = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program[SHADER_0], vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program[SHADER_0], fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program[SHADER_0], GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program[SHADER_0], GLKVertexAttribNormal, "normal");
    
    // Link program.
    if (![self linkProgram:_program[SHADER_0]]) {
        NSLog(@"Failed to link program: %d", _program[SHADER_0]);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program[SHADER_0]) {
            glDeleteProgram(_program[SHADER_0]);
            _program[SHADER_0] = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[SHADER_0][UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program[SHADER_0], "modelViewProjectionMatrix");
    uniforms[SHADER_0][UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program[SHADER_0], "normalMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program[SHADER_0], vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program[SHADER_0], fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)loadShaders1
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program[SHADER_1] = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader1" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader1" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program[SHADER_1], vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program[SHADER_1], fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program[SHADER_1], GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program[SHADER_1], GLKVertexAttribNormal, "normal");
    
    // Link program.
    if (![self linkProgram:_program[SHADER_1]]) {
        NSLog(@"Failed to link program: %d", _program[SHADER_1]);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program[SHADER_1]) {
            glDeleteProgram(_program[SHADER_1]);
            _program[SHADER_1] = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[SHADER_1][UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program[SHADER_0], "modelViewProjectionMatrix");
    uniforms[SHADER_1][UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program[SHADER_0], "normalMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program[SHADER_1], vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program[SHADER_1], fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
