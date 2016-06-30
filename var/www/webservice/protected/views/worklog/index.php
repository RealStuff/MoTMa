<?php
/* @var $this WorklogController */
/* @var $dataProvider CActiveDataProvider */

$this->breadcrumbs=array(
	'Worklogs',
);

$this->menu=array(
	array('label'=>'Create Worklog', 'url'=>array('create')),
	array('label'=>'Manage Worklog', 'url'=>array('admin')),
);
?>

<h1>Worklogs</h1>

<?php $this->widget('zii.widgets.CListView', array(
	'dataProvider'=>$dataProvider,
	'itemView'=>'_view',
)); ?>
