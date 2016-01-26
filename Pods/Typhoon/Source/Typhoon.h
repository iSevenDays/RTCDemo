////////////////////////////////////////////////////////////////////////////////
//
//  TYPHOON FRAMEWORK
//  Copyright 2013, Typhoon Framework Contributors
//  All Rights Reserved.
//
//  NOTICE: The authors permit you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

//! Project version number for Typhoon.
FOUNDATION_EXPORT double TyphoonVersionNumber;

//! Project version string for Typhoon.
FOUNDATION_EXPORT const unsigned char TyphoonVersionString[];

#import "TyphoonAssembly.h"
#import "TyphoonDefinition.h"
#import "TyphoonFactoryDefinition.h"
#import "TyphoonDefinition+Infrastructure.h"
#import "TyphoonMethod.h"
#import "TyphoonConfigPostProcessor.h"
#import "TyphoonResource.h"
#import "TyphoonBundleResource.h"
#import "TyphoonComponentFactory.h"
#import "TyphoonComponentFactory+InstanceBuilder.h"
#import "TyphoonDefinitionPostProcessor.h"
#import "TyphoonInstancePostProcessor.h"
#import "TyphoonIntrospectionUtils.h"
#import "TyphoonCollaboratingAssemblyProxy.h"
#import "NSObject+FactoryHooks.h"
#import "TyphoonTestUtils.h"
#import "TyphoonPatcher.h"

#import "TyphoonBlockComponentFactory.h"
#import "TyphoonAssemblyActivator.h"

#import "TyphoonAutoInjection.h"

#import "TyphoonDefinitionNamespace.h"
#import "TyphoonDefinition+Namespacing.h"

#if TARGET_OS_IPHONE
#import "TyphooniOS.h"
#endif

