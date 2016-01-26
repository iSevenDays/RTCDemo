//
//  ModuleAssemblyBase.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/24/16.
//  Copyright © 2016 anton. All rights reserved.
//


#import <Typhoon/Typhoon.h>

@protocol ServiceComponents;

@interface ModuleAssemblyBase : TyphoonAssembly

@property (strong, nonatomic, readonly) TyphoonAssembly <ServiceComponents> *serviceComponents;

@end
