//
//  ViewController.m
//  PhotoBrowser
//
//  Created by LeungChaos on 16/7/1.
//  Copyright © 2016年 liang. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewController.h"
#import "TableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toCollectionView {

    CollectionViewController *vc = [[CollectionViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
    

}

- (IBAction)toTableView {

    TableViewController *vc = [[TableViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
