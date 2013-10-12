//
//  Takes a filePath to a Video and crops it like Instagram, then deletes the original video
//  Created by Juan Manuel Serruya on 2013-05-21.
//

-(void)CropVideo:(NSURL*) filePath : (BOOL) forceToPortrait : (BOOL) deleteOriginalVideo{
   
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* outputPath = [docFolder stringByAppendingPathComponent:@"videooutput.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath])
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
    
    AVAsset* originalAsset = [AVAsset assetWithURL:filePath];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    [composition  addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack *originalAssetTrack = [[originalAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = CGSizeMake(originalAssetTrack.naturalSize.height, originalAssetTrack.naturalSize.height);
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30) );
    
    if (forceToPortrait){
        AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:originalAssetTrack];
        CGAffineTransform t1 = CGAffineTransformMakeTranslation(originalAssetTrack.naturalSize.height, -(originalAssetTrack.naturalSize.width - originalAssetTrack.naturalSize.height) /2 );
        CGAffineTransform t2 = CGAffineTransformRotate(t1, M_PI_2);
    
        CGAffineTransform finalTransform = t2;
        [transformer setTransform:finalTransform atTime:kCMTimeZero];
        instruction.layerInstructions = [NSArray arrayWithObject:transformer];
        videoComposition.instructions = [NSArray arrayWithObject: instruction];
    }
    
    AVAssetExportSession* exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality] ;
    exporter.videoComposition = videoComposition;
    exporter.outputURL=[NSURL fileURLWithPath:outputPath];
    exporter.outputFileType=AVFileTypeQuickTimeMovie;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^(void){
        NSLog(@"FinishedExporting!");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@", filePath.absoluteString);
            if (deleteOriginalVideo && [[NSFileManager defaultManager] fileExistsAtPath:filePath.absoluteString]){
                [[NSFileManager defaultManager] removeItemAtPath:filePath.absoluteString error:nil];
            }

        }
        );
    }];
}