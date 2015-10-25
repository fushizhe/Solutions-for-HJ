/*
1、简要描述观察者模式，并运用此模式编写一段代码；

观察者模式定义了一种一对多的依赖关系，让多个观察者对象同时监听
某一个主题对象。当这个对象在状态上发生变化时，会通知所有观察者
对象，让它们能够自动更新自己。

在iOS中，观察者模式主要有两种实现方式：Notification和Key-Value Observing(KVO),
下面分别用代码举例。
*/

/*Notification模式
*/

//NotificationCenter发布消息方式如下：

NSNotification *msg = [NSNotification notificationWithName:aSampleMsg object:self];
NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
[NotificationCenter postNotification:broadCastMessage];

//订阅相关事件的方式如下
NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
[NSNotificationCenter addObserver: self  selector: @selector (update:) name:aNotification  object:nil ];


/*KVO模式,提供一种机制，当指定的对象的属性被修改后，对象就会接受到通知。每次指定的被观察的对象的属性被修改后，KVO就会自动通知相应的观察者。
假设某个类中有一个view管理图标的图片logoImage，可以在这个类中添加代码
*/
[logoImage addObserver:self forKeyPath:@"image" options:0 context:nil];

//需要在dealloc中销毁该observer
-(void)dealloc {
	[logoImage removeOvserver:self forKeyPath:@"image"];
}

//实现如下的方法，则观察的属性改变时，都会执行这个方法
- (void)observerValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([KeyPath isEqualToString:@“image”]) {
        //do something...
    }
}