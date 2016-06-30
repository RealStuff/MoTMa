<?php
/* @var $this TicketitemController */
/* @var $model Ticketitem */
/* @var $form CActiveForm */
?>

<div class="form">

<?php $form=$this->beginWidget('CActiveForm', array(
	'id'=>'ticketitem-form',
	// Please note: When you enable ajax validation, make sure the corresponding
	// controller action is handling ajax validation correctly.
	// There is a call to performAjaxValidation() commented in generated controller code.
	// See class documentation of CActiveForm for details on this.
	'enableAjaxValidation'=>false,
)); ?>

	<p class="note">Fields with <span class="required">*</span> are required.</p>

	<?php echo $form->errorSummary($model); ?>

	<div class="row">
		<?php echo $form->labelEx($model,'fk_idcontact'); ?>
		<?php echo $form->textField($model,'fk_idcontact'); ?>
		<?php echo $form->error($model,'fk_idcontact'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'fk_idincident'); ?>
		<?php echo $form->textField($model,'fk_idincident'); ?>
		<?php echo $form->error($model,'fk_idincident'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'partnerincidentnumber'); ?>
		<?php echo $form->textField($model,'partnerincidentnumber'); ?>
		<?php echo $form->error($model,'partnerincidentnumber'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'templatenumber'); ?>
		<?php echo $form->textField($model,'templatenumber'); ?>
		<?php echo $form->error($model,'templatenumber'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'incidentnumber'); ?>
		<?php echo $form->textField($model,'incidentnumber'); ?>
		<?php echo $form->error($model,'incidentnumber'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'status'); ?>
		<?php echo $form->textField($model,'status'); ?>
		<?php echo $form->error($model,'status'); ?>
	</div>

	<div class="row buttons">
		<?php echo CHtml::submitButton($model->isNewRecord ? 'Create' : 'Save'); ?>
	</div>

<?php $this->endWidget(); ?>

</div><!-- form -->