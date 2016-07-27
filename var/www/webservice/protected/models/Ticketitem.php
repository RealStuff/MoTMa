<?php

/**
 * This is the model class for table "ticketitem".
 *
 * The followings are the available columns in table 'ticketitem':
 * @property integer $idticketitem
 * @property integer $fk_idcontact
 * @property integer $fk_idincident
 * @property string $partnerincidentnumber
 * @property string $templatenumber
 * @property string $incidentnumber
 * @property string $status
 *
 * The followings are the available model relations:
 * @property Incident $fkIdincident
 * @property Contact $fkIdcontact
 * @property Worklog[] $worklogs
 */
class Ticketitem extends CActiveRecord
{
    /**
     * @var string partnerindicentnumber
     * @soap
     */
    public $partnerincidentnumber;
    /**
     * @var string incidentnumber
     * @soap
     */
    public $incidentnumber;
    /**
     * @var string status
     * @soap
     */
     public $status;
    
    /**
     * @return string the associated database table name
     */
    public function tableName()
    {
        return 'ticketitem';
    }

    /**
     * @return array validation rules for model attributes.
     */
    public function rules()
    {
        // NOTE: you should only define rules for those attributes that
        // will receive user inputs.
        return array(
            array('partnerincidentnumber, templatenumber, incidentnumber', 'required'),
            array('fk_idcontact, fk_idincident', 'numerical', 'integerOnly'=>true),
            array('status', 'safe'),
            // The following rule is used by search().
            // @todo Please remove those attributes that should not be searched.
            array('idticketitem, fk_idcontact, fk_idincident, partnerincidentnumber, templatenumber, incidentnumber, status', 'safe', 'on'=>'search'),
        );
    }

    /**
     * @return array relational rules.
     */
    public function relations()
    {
        // NOTE: you may need to adjust the relation name and the related
        // class name for the relations automatically generated below.
        return array(
            'fkIdincident' => array(self::BELONGS_TO, 'Incident', 'fk_idincident'),
            'fkIdcontact' => array(self::BELONGS_TO, 'Contact', 'fk_idcontact'),
            'worklogs' => array(self::HAS_MANY, 'Worklog', 'fk_idticketitem'),
        );
    }

    /**
     * @return array customized attribute labels (name=>label)
     */
    public function attributeLabels()
    {
        return array(
            'idticketitem' => 'Idticketitem',
            'fk_idcontact' => 'Fk Idcontact',
            'fk_idincident' => 'Fk Idincident',
            'partnerincidentnumber' => 'Partnerincidentnumber',
            'templatenumber' => 'Templatenumber',
            'incidentnumber' => 'Incidentnumber',
            'status' => 'Status',
        );
    }

    /**
     * Retrieves a list of models based on the current search/filter conditions.
     *
     * Typical usecase:
     * - Initialize the model fields with values from filter form.
     * - Execute this method to get CActiveDataProvider instance which will filter
     * models according to data in model fields.
     * - Pass data provider to CGridView, CListView or any similar widget.
     *
     * @return CActiveDataProvider the data provider that can return the models
     * based on the search/filter conditions.
     */
    public function search()
    {
        // @todo Please modify the following code to remove attributes that should not be searched.

        $criteria=new CDbCriteria;

        $criteria->compare('idticketitem',$this->idticketitem);
        $criteria->compare('fk_idcontact',$this->fk_idcontact);
        $criteria->compare('fk_idincident',$this->fk_idincident);
        $criteria->compare('partnerincidentnumber',$this->partnerincidentnumber,true);
        $criteria->compare('templatenumber',$this->templatenumber,true);
        $criteria->compare('incidentnumber',$this->incidentnumber,true);
        $criteria->compare('status',$this->status,true);

        return new CActiveDataProvider($this, array(
            'criteria'=>$criteria,
        ));
    }

    /**
     * Returns the static model of the specified AR class.
     * Please note that you should have this exact method in all your CActiveRecord descendants!
     * @param string $className active record class name.
     * @return Ticketitem the static model class
     */
    public static function model($className=__CLASS__)
    {
        return parent::model($className);
    }
}