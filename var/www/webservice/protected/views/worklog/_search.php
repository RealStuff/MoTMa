<?php
/* @var $this WorklogController */
/* @var $model Worklog */
/* @var $form CActiveForm */
?>

<div class="wide form">

<?php $form=$this->beginWidget('CActiveForm', array(
	'action'=>Yii::app()->createUrl($this->route),
	'method'=>'get',
)); ?>

	<div class="row">
		<?php echo $form->label($model,'idworklog'); ?>
		<?php echo $form->textField($model,'idworklog'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'description'); ?>
		<?php echo $form->textField($model,'description'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'detail'); ?>
		<?php echo $form->textField($model,'detail'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'submitdate'); ?>
		<?php echo $form->textField($model,'submitdate'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'worklogid'); ?>
		<?php echo $form->textField($model,'worklogid'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'fk_idticketitem'); ?>
		<?php echo $form->textField($model,'fk_idticketitem'); ?>
	</div>

	<div class="row buttons">
		<?php echo CHtml::submitButton('Search'); ?>
	</div>

<?php $this->endWidget(); ?>

</div><!-- search-form -->