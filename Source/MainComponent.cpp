#include "MainComponent.h"

#if USE_CUSTOM_GL_CONTEXT
#include "CustomOpenGLContext.mm"
#endif

//==============================================================================
MainComponent::MainComponent()
{
    // Make sure you set the size of the component after
    // you add any child components.
    setSize (800, 600);
    
#if USE_CUSTOM_GL_CONTEXT
    openGlContext = std::make_unique<CustomOpenGLContext>();
    jassert(openGlContext);
    openGlContext->attach(this);
#endif
}

MainComponent::~MainComponent()
{
    // This shuts down the GL system and stops the rendering calls.
#if !USE_CUSTOM_GL_CONTEXT
    shutdownOpenGL();
#endif
}

//==============================================================================
void MainComponent::initialise()
{
    // Initialise GL objects for rendering here.
}

void MainComponent::shutdown()
{
    // Free any GL objects created for rendering here.
}

void MainComponent::render()
{
    // This clears the context with a black background.
    juce::OpenGLHelpers::clear (juce::Colours::grey);

    using namespace juce::gl;
    
    glViewport(0, 0, getWidth(), getHeight());
    std::array<float, 6> vert = {
        0.f, 0.f,
        1.f, 0.f,
        0.5f, 1.f
    };
    glColor4f(1.f, 0.f, 0.f, 1.f);
    glEnableClientState(juce::gl::GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, vert.data());
    glDrawArrays(GL_TRIANGLES, 0, vert.size() / 2);
    glDisableClientState(GL_VERTEX_ARRAY);
}

//==============================================================================
void MainComponent::paint (juce::Graphics& g)
{
    // You can add your component specific drawing code here!
    // This will draw over the top of the openGL background.
}

void MainComponent::resized()
{
    // This is called when the MainComponent is resized.
    // If you add any child components, this is where you should
    // update their positions.
}
