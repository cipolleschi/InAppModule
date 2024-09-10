//
//  RCTNativeLocalStorage.m
//  InAppModule
//
//  Created by Riccardo Cipolleschi on 10/09/2024.
//

#import "RCTNativeLocalStorage.h"

@implementation RCTNativeLocalStorage

RCT_EXPORT_MODULE(NativeLocalStorage)

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params { 
  return std::make_shared<facebook::react::NativeLocalStorageSpecJSI>(params);
}

- (NSString *)getString:(NSString *)key { 
  return [NSUserDefaults.standardUserDefaults stringForKey:key];
}

- (void)setString:(NSString *)value key:(NSString *)key { 
  [NSUserDefaults.standardUserDefaults setObject:value forKey:key];
}

@end
