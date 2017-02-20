//
//  TableViewController.m
//  DZ33-34TableViewNavigation
//
//  Created by Vasilii on 19.02.17.
//  Copyright © 2017 Vasilii Burenkov. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

//@property(strong, nonatomic) NSString* path;
@property(strong, nonatomic) NSArray* contents;


@end

@implementation TableViewController


-(id) initWhithFolderPath:(NSString*) path {// Метод инициализации UITableViewController c навигацией
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        
        self.path = path;
        //NSError* error = nil;
        
       // self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path
            //                                                                error:&error];//иницаализируем
        //if (error) {
       //     NSLog(@"%@", [error localizedDescription]);
        //}
   }
    return self;
}

- (void) setPath:(NSString *) path { // если self.path, то вызывается этот метод (переопределяем сеттер)
    
    _path = path; // во внутреннюю переменную кладем путь, с которым проинициализировался self.path
    
    NSError* error = nil;
    
    self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path
                                                                        error:&error]; // массив self.contents содержит контент директории по соответствующему пути (path) - файлы и папки
    
    if (error) {
        
        NSLog(@"%@", [error localizedDescription]); // Если где-то что-то не так проинициализировалось, нам выведут ошибку.
        
    }
    
    [self.tableView reloadData]; // Перезагружаем tableView, чтобы отобразилось содержимое корневой директории
    
    self.navigationItem.title = [self.path lastPathComponent]; // Заголовок - название после последнего слеша
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [self.path lastPathComponent];//название последнего компонента пути
    
    self.navigationItem.title=[self.path lastPathComponent];//только последний элемент
    if ([self.navigationController.viewControllers count]>1) {
        UIBarButtonItem *item=[[UIBarButtonItem alloc]initWithTitle:@"Root"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(actionRoot:)];//возвращемся сразу на главный
        self.navigationItem.rightBarButtonItem=item;//добавлем на навигайшен как правую кнопк
    }
    
    if (!self.path) {
        
        self.path = @"/";
    }

}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];//делаем для наследников
    NSLog(@"Path=%@. ViewController=%@. Index Current ViewController:%@",
          self.path,
          @([self.navigationController.viewControllers count]),//сколько контроллеров на стеке
          @([self.navigationController.viewControllers indexOfObject:self]));// индекс моего котроллера
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL) isDirectoryAtIndexPath: (NSIndexPath*) indexPath{//определяем это деректория или нет
    NSString *fileName=[self.contents objectAtIndex:indexPath.row];
    NSString *filePath=[self.path stringByAppendingPathComponent:fileName];
    //    NSLog(@"self.path=%@,filePath=%@,fileName=%@",self.path,filePath,fileName);
    
    BOOL isDirectory=NO;
    
    ;
    if (!  [[NSFileManager defaultManager]fileExistsAtPath:filePath isDirectory:&isDirectory]) NSLog(@"fileExistsAtPath No");
    return isDirectory;
    
}

#pragma mark - action
-(void) actionRoot:(UIBarButtonItem*) sender{//акшен для кнопки возвращение
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
   return 1;
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.contents.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *fileName=[self.contents objectAtIndex:indexPath.row];//количество рядов - элементов в массиве
    cell.textLabel.text=fileName;
    if ([self isDirectoryAtIndexPath:indexPath]) { //если деректория
        cell.imageView.image=[UIImage imageNamed:@"folder.png"];
    }
    else{
        cell.imageView.image=[UIImage imageNamed:@"file.png"];
        
    }
    return cell;

}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//делаем его не активным
    if([self isDirectoryAtIndexPath:indexPath]){//используем ранее созданный метод
        NSString *fileName=[self.contents objectAtIndex:indexPath.row];
        NSString *filePath=[self.path stringByAppendingPathComponent:fileName];
        TableViewController *controller= [[TableViewController alloc] initWhithFolderPath:filePath]; //в нашем котроллере создаем контроллер
        [[self navigationController]  pushViewController:controller animated:YES];//добавляем контроллер
    }

}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
