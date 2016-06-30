<?php
/* @var $this WorklogController */
/* @var $model Worklog */

$this->breadcrumbs=array(
	'Worklogs'=>array('index'),
	$model->idworklog,
);

$this->menu=array(
	array('label'=>'List Worklog', 'url'=>array('index')),
	array('label'=>'Create Worklog', 'url'=>array('create')),
	array('label'=>'Update Worklog', 'url'=>array('update', 'id'=>$model->idworklog)),
	array('label'=>'Delete Worklog', 'url'=>'#', 'linkOptions'=>array('submit'=>array('delete','id'=>$model->idworklog),'confirm'=>'Are you sure you want to delete this item?')),
	array('label'=>'Manage Worklog', 'url'=>array('admin')),
);
?>

<h1>View Worklog #<?php echo $model->idworklog; ?></h1>

<?php $this->widget('zii.widgets.CDetailView', array(
	'data'=>$model,
	'attributes'=>array(
		'idworklog',
		'description',
		'detail',
		'submitdate',
		'worklogid',
		'fk_idticketitem',
	),
)); ?>
