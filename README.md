# JacksViewZoomOut
/*  * 实现图片（任意View）的放大查看。  1.可以是约束布局的View，也可以是坐标(frame)布局的View  2.注意，因为放大View的时候，需要将View从原来视图移除，所以结束查看hide()之后，默认会将View直接添加在其原来的superView的最上层！  但是可以通过设置aboveView或者belowView(showView的兄弟视图)属性来控制showView在父视图中的层级。  3.目前只实现了一次查看一张图片（View）。  */
