//
//  TableViewController.h
//  DZ33-34TableViewNavigation
//
//  Created by Vasilii on 19.02.17.
//  Copyright © 2017 Vasilii Burenkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UITableViewController

@property(strong, nonatomic) NSString* path;

-(id) initWhithFolderPath:(NSString*) path; //конструктор куда передаем путь

@end
