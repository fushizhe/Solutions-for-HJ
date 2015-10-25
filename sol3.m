 /*解释以下代码的内存泄漏原因*/

/*
这段代码在block里面使用self，没有对self做weak的处理，造成了self持有cell，cell也持有self，
造成了强引用循环。
*/

@implementation HJTestViewController

... ...

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HJTestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestCell" forIndexPath:indexPath];
    
    [cell setTouchBlock:^(HJTestCell *cell) {
        [self refreshData];
    }];
    
    return cell;
}

... ...

@end

//可修改如下
@implementation HJTestViewController

... ...

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HJTestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestCell" forIndexPath:indexPath];

    //增加weakSelf
    __weak __typeof(self) weakSelf = self;
    [cell setTouchBlock:^(HJTestCell *cell) {
        //[self refreshData];

        //block内新增strongSelf
        __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf refreshData];
        
    }];
    
    return cell;
}

... ...

@end