//
//  AppDelegate.h
//  zhuangxiu
//
//  Created by 家乐淘 on 2019/12/30.
//  Copyright © 2019 zhuangxiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

