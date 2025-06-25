#pragma once

#include <JuceHeader.h>

class CustomOpenGLRenderer : public juce::Component
{
public:
    
    virtual void initialise() = 0;
    virtual void shutdown() = 0;
    virtual void render() = 0;
};
