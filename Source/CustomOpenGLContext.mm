#include "CustomOpenGLRenderer.h"
#import <Cocoa/Cocoa.h>

class CustomOpenGLContext
{
public:
    
    CustomOpenGLContext() = default;
    ~CustomOpenGLContext()
    {
        if(renderThread && renderThread->isThreadRunning()){
            renderThread->stopThread(30);
        }
    }
    
    void attach(CustomOpenGLRenderer* r)
    {
        jassert(r != nullptr);
        renderer = r;
        
        NSRect frame = NSMakeRect(0, 0, r->getWidth(), r->getHeight());
        
        NSOpenGLPixelFormatAttribute attrs[] = {
            NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersionLegacy,
            NSOpenGLPFAClosestPolicy,
            NSOpenGLPFANoRecovery,
            NSOpenGLPFAColorSize, 24,
            NSOpenGLPFAAlphaSize, 8,
            NSOpenGLPFADoubleBuffer,
            NSOpenGLPFAAccelerated,
            0
        };
        NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
        view = [[NSOpenGLView alloc] initWithFrame:frame pixelFormat:format];

        attachmentHelper = std::make_unique<AttachmentHelper>(renderer, *this);
        
        renderThread = std::make_unique<RenderThread>(*this);
        jassert(renderThread);
        jassert(renderThread->startThread());
    }
    
private:
    
    class RenderThread : public juce::Thread
    {
    public:
        
        RenderThread(CustomOpenGLContext& ctx)
        : juce::Thread("OpenGL Render Thread")
        , context(ctx)
        {}
        
        void run() final
        {
            while(!threadShouldExit()){
                context.renderFrame();
                sleep(20);
            }
        };
        
    private:
        CustomOpenGLContext& context;
    };
    
    class AttachmentHelper : public juce::ComponentMovementWatcher
    {
    public:
        AttachmentHelper(CustomOpenGLRenderer* renderer, CustomOpenGLContext& ctx)
        : juce::ComponentMovementWatcher(renderer)
        , context(ctx)
        {
            componentPeerChanged();
        }
        
        void componentMovedOrResized (bool, bool) override
        {
            context.resizeView();
        };
        void componentVisibilityChanged() override {};
        void componentPeerChanged() override
        {
            context.updateViewAttachment();
        }
        
    private:
        CustomOpenGLContext& context;

    };
    
    void renderFrame()
    {
        NSOpenGLContext* context = [view openGLContext];
        [context makeCurrentContext];
        renderer->render();
        [context flushBuffer];
        [NSOpenGLContext clearCurrentContext];
    }
    
    void updateViewAttachment()
    {
        jassert(view != nil && renderer != nullptr);
        
        if (auto* peer = renderer->getPeer())
        {
            NSView* parentView = [view superview];
            if(parentView != nil){
                [view removeFromSuperview];
            }
            auto peerView = (NSView*) peer->getNativeHandle();
            [peerView addSubview: view];
        }
    }
    
    void resizeView()
    {
        jassert(view != nil && renderer != nullptr);

        NSRect frame = NSMakeRect(0, 0, renderer->getWidth(), renderer->getHeight());
        [view setFrame:frame];
    }
    
    CustomOpenGLRenderer* renderer = nullptr;
    NSOpenGLView* view = nil;
    std::unique_ptr<RenderThread> renderThread = nullptr;
    std::unique_ptr<AttachmentHelper> attachmentHelper = nullptr;
};
