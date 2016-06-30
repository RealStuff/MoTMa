<?php
/* @var $this IncidentController */
/* @var $model Incident */
/* @var $form CActiveForm */
?>

<div class="form">

<?php $form=$this->beginWidget('CActiveForm', array(
	'id'=>'incident-form',
	// Please note: When you enable ajax validation, make sure the corresponding
	// controller action is handling ajax validation correctly.
	// There is a call to performAjaxValidation() commented in generated controller code.
	// See class documentation of CActiveForm for details on this.
	'enableAjaxValidation'=>false,
)); ?>

	<p class="note">Fields with <span class="required">*</span> are required.</p>

	<?php echo $form->errorSummary($model); ?>

	<div class="row">
		<?php echo $form->labelEx($model,'priority'); ?>
		<?php echo $form->textField($model,'priority'); ?>
		<?php echo $form->error($model,'priority'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'impact'); ?>
		<?php echo $form->textField($model,'impact'); ?>
		<?php echo $form->error($model,'impact'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'urgency'); ?>
		<?php echo $form->textField($model,'urgency'); ?>
		<?php echo $form->error($model,'urgency'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'description'); ?>
		<?php echo $form->textField($model,'description'); ?>
		<?php echo $form->error($model,'description'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'detail'); ?>
		<?php echo $form->textField($model,'detail'); ?>
		<?php echo $form->error($model,'detail'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'submitdate'); ?>
		<?php echo $form->textField($model,'submitdate'); ?>
		<?php echo $form->error($model,'submitdate'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'targetresolutiondate'); ?>
		<?php echo $form->textField($model,'targetresolutiondate'); ?>
		<?php echo $form->error($model,'targetresolutiondate'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'customer'); ?>
		<?php echo $form->textField($model,'customer',array('size'=>0,'maxlength'=>0)); ?>
		<?php echo $form->error($model,'customer'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'productname'); ?>
		<?php echo $form->textField($model,'productname'); ?>
		<?php echo $form->error($model,'productname'); ?>
	</div>

	<div class="row buttons">
		<?php echo CHtml::submitButton($model->isNewRecord ? 'Create' : 'Save'); ?>
	</div>

<?php $this->endWidget(); ?>

</div><!-- form -->