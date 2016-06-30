<?php
/* @var $this WorklogController */
/* @var $model Worklog */

$this->breadcrumbs=array(
	'Worklogs'=>array('index'),
	'Create',
);

$this->menu=array(
	array('label'=>'List Worklog', 'url'=>array('index')),
	array('label'=>'Manage Worklog', 'url'=>array('admin')),
);
?>

<h1>Create Worklog</h1>

<?php $this->renderPartial('_form', array('model'=>$model)); ?>