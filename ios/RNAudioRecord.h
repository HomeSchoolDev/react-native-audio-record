#import <AVFoundation/AVFoundation.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTLog.h>

#define kNumberBuffers 3

typedef struct {
    __unsafe_unretained id      mSelf;
    AudioStreamBasicDescription mDataFormat;
    AudioQueueRef               mQueue;
    AudioQueueBufferRef         mBuffers[kNumberBuffers];
    AudioFileID                 mAudioFile;
    UInt32                      bufferByteSize;
    SInt64                      mCurrentPacket;
    bool                        mIsRunning;
} AQRecordState;

@interface RNAudioRecord : RCTEventEmitter <RCTBridgeModule, AVAudioRecorderDelegate>
    @property (nonatomic, assign) AQRecordState recordState;
    @property (nonatomic, strong) NSString* filePath;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@end
