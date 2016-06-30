<?php
/* @var $this WorklogController */
/* @var $model Worklog */

$this->breadcrumbs=array(
	'Worklogs'=>array('index'),
	$model->idworklog=>array('view','id'=>$model->idworklog),
	'Update',
);

$this->menu=array(
	array('label'=>'List Worklog', 'url'=>array('index')),
	array('label'=>'Create Worklog', 'url'=>array('create')),
	array('label'=>'View Worklog', 'url'=>array('view', 'id'=>$model->idworklog)),
	array('label'=>'Manage Worklog', 'url'=>array('admin')),
);
?>

<h1>Update Worklog <?php echo $model->idworklog; ?></h1>

<?php $this->renderPartial('_form', array('model'=>$model)); ?>