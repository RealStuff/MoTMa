<?php

/**
 * This is the model class for table "worklog".
 *
 * The followings are the available columns in table 'worklog':
 * @property integer $idworklog
 * @property string $description
 * @property string $detail
 * @property string $submitdate
 * @property string $worklogid
 * @property integer $fk_idticketitem
 *
 * The followings are the available model relations:
 * @property Ticketitem $fkIdticketitem0
 */
class Worklog extends CActiveRecord
{
	/**
	 * @var string
	 * @soap
	 */
	public $description;
	
	/**
	 * @var string
	 * @soap
	 */
	public $detail;
	
	/**
	 * @var string
	 * @soap
	 */
	public $submitdate;
	
	/**
	 * @var string
	 * @soap
	 */
	public $worklogid;

    
    /**
     * @return string the associated database table name
     */
    public function tableName()
    {
        return 'worklog';
    }

    /**
     * @return array validation rules for model attributes.
     */
    public function rules()
    {
        // NOTE: you should only define rules for those attributes that
        // will receive user inputs.
        return array(
            array('description, detail, submitdate, worklogid, fk_idticketitem', 'safe'),
            // The following rule is used by search().
            // @todo Please remove those attributes that should not be searched.
            array('idworklog, description, detail, submitdate, worklogid, fk_idticketitem', 'safe', 'on'=>'search'),
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
            'fkIdticketitem0' => array(self::BELONGS_TO, 'Ticketitem', 'fk_idticketitem'),
        );
    }

    /**
     * @return array customized attribute labels (name=>label)
     */
    public function attributeLabels()
    {
        return array(
            'idworklog' => 'Idworklog',
            'description' => 'Description',
            'detail' => 'Detail',
            'submitdate' => 'Submitdate',
            'worklogid' => 'Worklogid',
            'fk_idticketitem' => 'Idticketitem',
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

        $criteria->compare('idworklog',$this->idworklog);
        $criteria->compare('description',$this->description,true);
        $criteria->compare('detail',$this->detail,true);
        $criteria->compare('submitdate',$this->submitdate,true);
        $criteria->compare('worklogid',$this->worklogid,true);
        $criteria->compare('fk_idticketitem',$this->fk_idticketitem,true);

        return new CActiveDataProvider($this, array(
            'criteria'=>$criteria,
        ));
    }

    /**
     * Returns the static model of the specified AR class.
     * Please note that you should have this exact method in all your CActiveRecord descendants!
     * @param string $className active record class name.
     * @return Worklog the static model class
     */
    public static function model($className=__CLASS__)
    {
        return parent::model($className);
    }
}
