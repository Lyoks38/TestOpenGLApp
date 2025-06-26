#pragma once

#include <JuceHeader.h>

// Set this macro to 1 to use custom OpenGL renderer
#define USE_CUSTOM_GL_CONTEXT 0

#if USE_CUSTOM_GL_CONTEXT
#include "CustomOpenGLRenderer.h"
class CustomOpenGLContext;
#define MAIN_COMPONENT_CLASS CustomOpenGLRenderer
#else
#define MAIN_COMPONENT_CLASS juce::OpenGLAppComponent
#endif


class MainComponent  : public MAIN_COMPONENT_CLASS
{
public:
    //==============================================================================
    MainComponent();
    ~MainComponent() override;

    //==============================================================================
    void initialise() override;
    void shutdown() override;
    void render() override;

    //==============================================================================
    void paint (juce::Graphics& g) override;
    void resized() override;

private:
    
#if USE_CUSTOM_GL_CONTEXT
    std::unique_ptr<CustomOpenGLContext> openGlContext;
#endif

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (MainComponent)
};
