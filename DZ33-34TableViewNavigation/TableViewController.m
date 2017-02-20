//
//  TableViewController.m
//  DZ33-34TableViewNavigation
//
//  Created by Vasilii on 19.02.17.
//  Copyright © 2017 Vasilii Burenkov. All rights reserved.
//

#import "TableViewController.h"
#import "FileCell.h"

@interface TableViewController ()

//@property(strong, nonatomic) NSString* path;
@property(strong, nonatomic) NSArray* contents;
//@property(strong, nonatomic) NSString* selectedPath;

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
    
    
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];//делаем для наследников
    
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

    
    NSLog(@"Path=%@. ViewController=%@. Index Current ViewController:%@",
          self.path,
          @([self.navigationController.viewControllers count]),//сколько контроллеров на стеке
          @([self.navigationController.viewControllers indexOfObject:self]));// индекс моего котроллера
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*) fileSizeFromValue:(unsigned long long) size {//метод вывода формата данных для размера фаила
    
    static NSString* units[] = {@"B", @"KB", @"MB", @"GB", @"TB"};
    static int unitsCount = 5;
    
    int index = 0;
    
    double fileSize = (double)size;
    
    while (fileSize > 1024 && index < unitsCount) {
        
        fileSize = fileSize / 1024;
        
        index++;
        
    }
    
    return [NSString stringWithFormat:@"%.2f %@", fileSize, units[index]];
    
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

-(IBAction) actiionInfoCell:(id)sender {
    NSLog(@"actionCell");
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
    //return [self.contents count]//Ни чем не отличаются, но Геттер лучше вызывать с помощью [], а сеттер через точку
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* fileIdentifier = @"FileCell";
    static NSString* folderIdentifier = @"FolderCell";
    
    NSString *fileName=[self.contents objectAtIndex:indexPath.row];//количество рядов - элементов в массиве
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        // если в ячейке директория
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:folderIdentifier];
        
        cell.textLabel.text=fileName;
        
        return cell;
        
    } else {
        
        NSString* path = [self.path stringByAppendingPathComponent:fileName];
        
        NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        
        FileCell *cell = [tableView dequeueReusableCellWithIdentifier:fileIdentifier];
        
        cell.fileName.text = fileName;
        cell.fileSize.text = [self fileSizeFromValue:[attributes fileSize]];
        cell.fileDate.text = [NSString stringWithFormat:@"%@", [attributes fileModificationDate]];
        
        return cell;
    }
  
    return nil;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {//метод задает высоту ячейки
    if ([self isDirectoryAtIndexPath:indexPath]) {
        return 44.f;
    }else {
        return 80.f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//делаем его не активным
    if([self isDirectoryAtIndexPath:indexPath]){//используем ранее созданный метод
        NSString *fileName=[self.contents objectAtIndex:indexPath.row];
        NSString * path=[self.path stringByAppendingPathComponent:fileName];
        //TableViewController *controller= [[TableViewController alloc] initWhithFolderPath:filePath]; //в нашем котроллере создаем контроллер
        //[[self navigationController]  pushViewController:controller animated:YES];//добавляем контроллер
        
        //UIStoryboard* storyboard = self.storyboard;
        
       
        TableViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TableViewController"];//подгружает тот самый вью котроллер
        
        vc.path = path;
        
        [self.navigationController pushViewController:vc animated:YES];
         
        
        //self.selectedPath=path;
        
        //[self performSegueWithIdentifier:@"navigateDeep" sender:nil ];
    }

}

/*
#pragma mark-Segue
-(BOOL) shouldPerformSegueWithIdentifier:(nonnull NSString *)identifier sender:(nullable id)sender{
    NSLog(@"shouldPerformSegueWithIdentifier identifier:%@",identifier);
    return YES;
}
-(void) prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender{
    NSLog(@"prepareForSegue %@",segue.identifier);
    
    if([segue.identifier isEqualToString:@"navigateDeep"]){
        TableViewController *destinationController=segue.destinationViewController;
        TableViewController *sourceController=segue.sourceViewController;
        destinationController.path=sourceController.selectedPath;
        
    }
    
}
*/

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
