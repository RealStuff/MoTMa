<?php
/* @var $this TicketitemController */
/* @var $model Ticketitem */
/* @var $form CActiveForm */
?>

<div class="wide form">

<?php $form=$this->beginWidget('CActiveForm', array(
	'action'=>Yii::app()->createUrl($this->route),
	'method'=>'get',
)); ?>

	<div class="row">
		<?php echo $form->label($model,'idticketitem'); ?>
		<?php echo $form->textField($model,'idticketitem'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'fk_idcontact'); ?>
		<?php echo $form->textField($model,'fk_idcontact'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'fk_idincident'); ?>
		<?php echo $form->textField($model,'fk_idincident'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'partnerincidentnumber'); ?>
		<?php echo $form->textField($model,'partnerincidentnumber'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'templatenumber'); ?>
		<?php echo $form->textField($model,'templatenumber'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'incidentnumber'); ?>
		<?php echo $form->textField($model,'incidentnumber'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'status'); ?>
		<?php echo $form->textField($model,'status'); ?>
	</div>

	<div class="row buttons">
		<?php echo CHtml::submitButton('Search'); ?>
	</div>

<?php $this->endWidget(); ?>

</div><!-- search-form -->