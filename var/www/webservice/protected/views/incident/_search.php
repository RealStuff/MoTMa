<?php
/* @var $this IncidentController */
/* @var $model Incident */
/* @var $form CActiveForm */
?>

<div class="wide form">

<?php $form=$this->beginWidget('CActiveForm', array(
	'action'=>Yii::app()->createUrl($this->route),
	'method'=>'get',
)); ?>

	<div class="row">
		<?php echo $form->label($model,'idincident'); ?>
		<?php echo $form->textField($model,'idincident'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'priority'); ?>
		<?php echo $form->textField($model,'priority'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'impact'); ?>
		<?php echo $form->textField($model,'impact'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'urgency'); ?>
		<?php echo $form->textField($model,'urgency'); ?>
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
		<?php echo $form->label($model,'targetresolutiondate'); ?>
		<?php echo $form->textField($model,'targetresolutiondate'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'customer'); ?>
		<?php echo $form->textField($model,'customer',array('size'=>0,'maxlength'=>0)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'productname'); ?>
		<?php echo $form->textField($model,'productname'); ?>
	</div>

	<div class="row buttons">
		<?php echo CHtml::submitButton('Search'); ?>
	</div>

<?php $this->endWidget(); ?>

</div><!-- search-form -->