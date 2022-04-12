#import "RNAudioRecord.h"

@implementation RNAudioRecord

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(init:(NSDictionary *) options) {
    RCTLogInfo(@"init");
//    _recordState.mDataFormat.mSampleRate        = options[@"sampleRate"] == nil ? 44100 : [options[@"sampleRate"] doubleValue];
//    _recordState.mDataFormat.mBitsPerChannel    = options[@"bitsPerSample"] == nil ? 16 : [options[@"bitsPerSample"] unsignedIntValue];
//    _recordState.mDataFormat.mChannelsPerFrame  = options[@"channels"] == nil ? 1 : [options[@"channels"] unsignedIntValue];
//    _recordState.mDataFormat.mBytesPerPacket    = (_recordState.mDataFormat.mBitsPerChannel / 8) * _recordState.mDataFormat.mChannelsPerFrame;
//    _recordState.mDataFormat.mBytesPerFrame     = _recordState.mDataFormat.mBytesPerPacket;
//    _recordState.mDataFormat.mFramesPerPacket   = 1;
//    _recordState.mDataFormat.mReserved          = 0;
//    _recordState.mDataFormat.mFormatID          = kAudioFormatLinearPCM;
//    _recordState.mDataFormat.mFormatFlags       = _recordState.mDataFormat.mBitsPerChannel == 8 ? kLinearPCMFormatFlagIsPacked : (kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked);
//
//
//    _recordState.bufferByteSize = 2048;
//    _recordState.mSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *err = nil;
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        if(err) {
            NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
            return;
        }
        [audioSession setActive:YES error:&err];
        err = nil;
        if (err) {
            NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
            return;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleAudioSessionInterruption:)
                                                         name:AVAudioSessionInterruptionNotification
                                                       object:[AVAudioSession sharedInstance]];
        
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
        
        NSString *fileName = options[@"wavFile"] == nil ? @"audio.wav" : options[@"wavFile"];
//        NSString *fileName = @"audio_recording.m4a";
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        self->_filePath = [NSString stringWithFormat:@"%@/%@", docDir, fileName];
        NSURL *url = [NSURL fileURLWithPath:self->_filePath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:self->_filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:self->_filePath error:nil];
        }
        
        NSError *error = nil;
        self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&error];
        self.recorder.delegate = self;
        [self.recorder prepareToRecord];
    });
}

- (void)handleAudioSessionInterruption:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        AVAudioSessionInterruptionType interruptionType = [notification.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
        AVAudioSessionInterruptionOptions interruptionOption = [notification.userInfo[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];

        switch (interruptionType) {
            // 2. save recording on interruption begin
            case AVAudioSessionInterruptionTypeBegan:{
                // stop recording
                // Update the UI accordingly
                break;
            }
            case AVAudioSessionInterruptionTypeEnded:{
                if (interruptionOption == AVAudioSessionInterruptionOptionShouldResume) {
                    // create a new recording
                    // Update the UI accordingly
                }
                break;
            }

            default:
                break;
        }
    });
}

RCT_EXPORT_METHOD(start) {
    RCTLogInfo(@"start");

    // most audio players set session category to "Playback", record won't work in this mode
    // therefore set session category to "Record" before recording
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//
//    _recordState.mIsRunning = true;
//    _recordState.mCurrentPacket = 0;
//
//    CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)_filePath, NULL);
//    AudioFileCreateWithURL(url, kAudioFileWAVEType, &_recordState.mDataFormat, kAudioFileFlags_EraseFile, &_recordState.mAudioFile);
//    CFRelease(url);
//
//    AudioQueueNewInput(&_recordState.mDataFormat, HandleInputBuffer, &_recordState, NULL, NULL, 0, &_recordState.mQueue);
//    for (int i = 0; i < kNumberBuffers; i++) {
//        AudioQueueAllocateBuffer(_recordState.mQueue, _recordState.bufferByteSize, &_recordState.mBuffers[i]);
//        AudioQueueEnqueueBuffer(_recordState.mQueue, _recordState.mBuffers[i], 0, NULL);
//    }
//    AudioQueueStart(_recordState.mQueue, NULL);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.recorder record];
    });
}

RCT_EXPORT_METHOD(stop:(RCTPromiseResolveBlock)resolve
                  rejecter:(__unused RCTPromiseRejectBlock)reject) {
    RCTLogInfo(@"stop");
//    if (_recordState.mIsRunning) {
//        _recordState.mIsRunning = false;
//        AudioQueueStop(_recordState.mQueue, true);
//        AudioQueueDispose(_recordState.mQueue, true);
//        AudioFileClose(_recordState.mAudioFile);
//    }
//    resolve(_filePath);
//    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil] fileSize];
//    RCTLogInfo(@"file path %@", _filePath);
//    RCTLogInfo(@"file size %llu", fileSize);
//
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.recorder stop];
        self.recorder = nil;
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        
        if (error != nil) {
            NSLog(@"Failed to change audio category with error: %@", error);
        } else {
            resolve(self->_filePath);
        }
    });
}

//void HandleInputBuffer(void *inUserData,
//                       AudioQueueRef inAQ,
//                       AudioQueueBufferRef inBuffer,
//                       const AudioTimeStamp *inStartTime,
//                       UInt32 inNumPackets,
//                       const AudioStreamPacketDescription *inPacketDesc) {
//    AQRecordState* pRecordState = (AQRecordState *)inUserData;
//
//    if (!pRecordState->mIsRunning) {
//        return;
//    }
//
//    if (AudioFileWritePackets(pRecordState->mAudioFile,
//                              false,
//                              inBuffer->mAudioDataByteSize,
//                              inPacketDesc,
//                              pRecordState->mCurrentPacket,
//                              &inNumPackets,
//                              inBuffer->mAudioData
//                              ) == noErr) {
//        pRecordState->mCurrentPacket += inNumPackets;
//    }
//
//    short *samples = (short *) inBuffer->mAudioData;
//    long nsamples = inBuffer->mAudioDataByteSize;
//    NSData *data = [NSData dataWithBytes:samples length:nsamples];
//    NSString *str = [data base64EncodedStringWithOptions:0];
//    [pRecordState->mSelf sendEventWithName:@"data" body:str];
//
//    AudioQueueEnqueueBuffer(pRecordState->mQueue, inBuffer, 0, NULL);
//}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"data"];
}

- (void)dealloc {
    RCTLogInfo(@"dealloc");
    self.recorder = nil;
//    AudioQueueDispose(_recordState.mQueue, true);
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"Finished recording");
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error {
    NSLog(@"Audio recorder failed with error: %@", error);
}

@end
