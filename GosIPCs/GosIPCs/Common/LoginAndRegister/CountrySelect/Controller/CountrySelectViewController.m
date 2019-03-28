//
//  CountrySelectViewController.m
//  ULife3.5
//
//  Created by 罗乐 on 2019/1/22.
//  Copyright © 2019 GosCam. All rights reserved.
//

#import "CountrySelectViewController.h"

@interface CountrySelectViewController () <
                                            UISearchControllerDelegate,
                                            UISearchResultsUpdating,
//                                            UISearchBarDelegate,
                                            UITableViewDelegate,
                                            UITableViewDataSource,
                                            NSXMLParserDelegate
                                          >

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *searchView;

@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) NSString *startTag;

@property (nonatomic, strong) NSArray  *sortKeys;

@property (nonatomic, strong) NSMutableDictionary *numberDic;//key为国家名称，value为对应区号

@property (nonatomic, strong) NSMutableDictionary *sectionDic;//key为A-Z,#，value为对应分区array

@property (nonatomic, strong) NSMutableDictionary *selectSectionDic;//key为A-Z,#，value为对应分区array

@property (nonatomic, strong) NSMutableDictionary *showDic;//当前显示数据

@property (nonatomic, strong) NSString *countryKey;

@end

@implementation CountrySelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self parseXMLFile];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.searchView.subviews.count == 0) {
        [self addSearchBar];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchController setActive:NO];
    [self.searchController.searchBar setHidden:YES];
}

#pragma mark - lazy load
- (UISearchController *)searchController {
    if (!_searchController) {
        //创建UISearchController
        _searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
        //设置代理
        _searchController.delegate = self;
        _searchController.searchResultsUpdater= self;
        
        //设置UISearchController的显示属性，以下3个属性默认为YES
        //搜索时，背景变暗色
        _searchController.dimsBackgroundDuringPresentation = NO;
        //搜索时，背景变模糊
        if (@available(iOS 9.1, *)) {
            _searchController.obscuresBackgroundDuringPresentation = NO;
        } else {
            // Fallback on earlier versions
        }
        //隐藏导航栏
        _searchController.hidesNavigationBarDuringPresentation = NO;
        
        _searchController.searchBar.showsCancelButton = NO;
//        _searchController.searchBar.delegate = self;
    }
    return _searchController;
}

- (NSMutableDictionary *)getSectionDic {
    NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithCapacity:self.sortKeys.count];
    
    for (NSUInteger i = 0; i < self.sortKeys.count; i++) {
        [dic setObject:[[NSMutableArray alloc] init] forKey:self.sortKeys[i]];
    }
    return dic;
}

- (NSMutableDictionary *)sectionDic {
    if (!_sectionDic) {
        _sectionDic = [self getSectionDic];
    }
    return _sectionDic;
}

- (NSMutableDictionary *)selectSectionDic {
    if (!_selectSectionDic) {
        _selectSectionDic = [self getSectionDic];
    }
    return _selectSectionDic;
}

- (NSMutableDictionary *)numberDic {
    if (!_numberDic) {
        _numberDic = [[NSMutableDictionary alloc] init];
    }
    return _numberDic;
}

- (NSArray *)sortKeys {
    if (!_sortKeys) {
        _sortKeys = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#"];
    }
    return _sortKeys;
}

#pragma mark - 初始化
- (void)addSearchBar {
    CGRect frame = CGRectMake(0, 0, self.searchView.bounds.size.width, self.searchView.bounds.size.height);
    self.searchController.searchBar.frame = frame;
    [self.searchView addSubview:self.searchController.searchBar];
}

#pragma mark - xml解析
#pragma mark -- 开始解析
- (void)parseXMLFile {
    
    NSString *fileName;
    NSString *language = [NSLocale preferredLanguages].firstObject;
    
    if ([language hasPrefix:@"zh"]) {
        fileName = @"arrays_cn";
    } else
    {
        fileName = @"arrays_en";
    }
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"xml"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSData *data=[NSData dataWithContentsOfURL:url];
    
    NSXMLParser *parser=[[NSXMLParser alloc]initWithData:data];
    parser.delegate = self;
    
    [parser parse];
}

#pragma mark -- 获取汉字首字符
- (NSString *)firstCharactor:(NSString *)aString{
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}

#pragma mark -- NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{
    self.startTag = elementName;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (self.startTag) {
        if ([self.startTag isEqualToString:@"country"]) {
            self.countryKey = string;
            NSString *firstChar = [self firstCharactor:string];
            NSMutableArray *valueArr = self.sectionDic[firstChar];
            if (!valueArr) {
                valueArr = self.sectionDic[@"#"];
            }
            [valueArr addObject:[string copy]];
        } else if([self.startTag isEqualToString:@"num"]) {
            [self.numberDic setValue:string forKey:self.countryKey];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    self.startTag = nil;
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    self.showDic = self.sectionDic;
}

#pragma mark - tableView datasource
//分区数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.showDic.allKeys.count;
}

//设置各分区的行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *key = self.sortKeys[section];
    NSArray *valueArr = self.showDic[key];
    return [valueArr count];
}

//分区标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *key = self.sortKeys[section];
    NSArray *valueArr = self.showDic[key];
    if (valueArr && valueArr.count > 0) {
        return key;
    }
    return @"";
}

//头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *key = self.sortKeys[section];
    NSArray *valueArr = self.showDic[key];
    if (valueArr && valueArr.count > 0) {
        return 30;
    }
    return 0.1;
}

//尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

//返回单元格内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *flag=@"cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:flag];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:flag];
    }
    NSString *key = self.sortKeys[indexPath.section];
    NSArray *valueArr = self.showDic[key];
    [cell.textLabel setText:valueArr[indexPath.row]];
    return cell;
}

//快速索引
- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sortKeys;
}
- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = self.sortKeys[indexPath.section];
    NSArray *valueArr = self.showDic[key];
    NSString *country = valueArr[indexPath.row];
    self.resultBlock(country, self.numberDic[country]);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchControllerDelegate代理

//测试UISearchController的执行过程

- (void)willPresentSearchController:(UISearchController *)searchController
{
    NSLog(@"willPresentSearchController");
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    NSLog(@"didPresentSearchController");
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    NSLog(@"willDismissSearchController");
    self.showDic = self.sectionDic;
    //刷新表格
    [self.tableView reloadData];
}

- (void)didDismissSearchController:(UISearchController *)searchController
{
    NSLog(@"didDismissSearchController");
}

- (void)presentSearchController:(UISearchController *)searchController
{
    NSLog(@"presentSearchController");
}


-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSLog(@"updateSearchResultsForSearchController");
    NSString *searchString = [self.searchController.searchBar text];
    if (searchString.length == 0) {
        self.showDic = self.sectionDic;
        //刷新表格
        [self.tableView reloadData];
        return;
    }
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchString];

    //过滤数据
    for (NSUInteger i = 0; i < self.selectSectionDic.allKeys.count; i++) {
        NSString *key;
        key = self.selectSectionDic.allKeys[i];
        self.selectSectionDic[key] = [NSMutableArray arrayWithArray:[self.sectionDic[key] filteredArrayUsingPredicate:preicate]];
    }
    self.showDic = self.selectSectionDic;
    //刷新表格
    [self.tableView reloadData];
}

@end
