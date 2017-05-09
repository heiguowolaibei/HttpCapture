//
//  MJRefreshEnum.swift
//  weixindress
//
//  Created by 杨帆 on 16/2/24.
//  Copyright © 2016年 www.jd.com. All rights reserved.
//

import Foundation

var MJRefreshFooterStateNoMoreData:MJRefreshState{
    return MJRefreshState.NoMoreData
}

var MJRefreshFooterStateIdle:MJRefreshState{
    return MJRefreshState.Idle
}

var MJRefreshFooterStateRefreshing:MJRefreshState{
    return MJRefreshState.Refreshing
}


var MJRefreshHeaderStatePulling:MJRefreshState{
    return MJRefreshState.Pulling
}

var MJRefreshHeaderStateIdle:MJRefreshState{
    return MJRefreshState.Idle
}

var MJRefreshHeaderStateRefreshing:MJRefreshState{
    return MJRefreshState.Refreshing
}


var MJRefreshHeaderIdleText = "下拉可以刷新";
var MJRefreshHeaderPullingText = "松开立即刷新";
var MJRefreshHeaderRefreshingText = "正在刷新数据中...";

var MJRefreshAutoFooterIdleText = "点击或上拉加载更多";
var MJRefreshAutoFooterRefreshingText = "正在加载更多的数据...";
var MJRefreshAutoFooterNoMoreDataText = "已经全部加载完毕";

var MJRefreshBackFooterIdleText = "上拉可以加载更多";
var MJRefreshBackFooterPullingText = "松开立即加载更多";
var MJRefreshBackFooterRefreshingText = "正在加载更多的数据...";
var MJRefreshBackFooterNoMoreDataText = "已经全部加载完毕";


var MJRefreshHeaderStateIdleText = "下拉刷新";
var MJRefreshHeaderStatePullingText = "松开立即更新";
var MJRefreshHeaderStateRefreshingText = "正在更新...";

var MJRefreshFooterStateIdleText = "点击加载更多";
var MJRefreshFooterStateRefreshingText = "加载中...";
var MJRefreshFooterStateNoMoreDataText = "小主，没有更多了哦";

//var MJRefreshFooterStateNoMoreData:MJRefreshState{
//    return MJRefreshState.NoMoreData
//}
//var MJRefreshFooterStateNoMoreData:MJRefreshState{
//    return MJRefreshState.NoMoreData
//}



 