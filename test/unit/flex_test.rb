require 'test_helper'

class FlexTest < ActiveSupport::TestCase

  def setup
    @user = User.find_by_admin true
  end

  def test_flex_defaults
    flex = Flex.new
    assert_equal 0, flex.minutes
    assert_equal 0, flex.hours
    assert_equal true, flex.positive
    assert_equal false, flex.discarded
  end

  def test_valid_flex
    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 10,
                               :hours => 0,
                               :positive => true)
    assert_valid flex
    assert_equal 10, flex.minutes
    assert_equal 0, flex.hours
    @user.reload
    assert_equal '0:10', @user.flex_time
  end

    def test_valid_flex_hours_and_minutes
    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 10,
                               :hours => 1,
                               :positive => true)
    assert_valid flex
    assert_equal 10, flex.minutes
    assert_equal 1, flex.hours
    assert_equal 10, flex.total_minutes
    assert_equal 1, flex.total_hours
    @user.reload
    assert_equal '1:10', @user.flex_time
  end

    def test_valid_negative_flex
    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 10,
                               :hours => 0,
                               :positive => false)
    assert_valid flex
    assert_equal -10, flex.minutes
    assert_equal 0, flex.hours
    @user.reload
    assert_equal '-0:10', @user.flex_time
  end

  def test_minutes_convert_to_hours
    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 70,
                               :hours => 0,
                               :positive => true)
    assert_valid flex
    @user.reload
    assert_equal '1:10', @user.flex_time
  end

  def test_minutes_convert_to_hours_negative
    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 70,
                               :hours => 0,
                               :positive => false)
    assert_valid flex
    @user.reload
    assert_equal '-1:10', @user.flex_time
  end

  def test_minutes_convert_to_hours_and_add
    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 70,
                               :hours => 1,
                               :positive => true)
    assert_valid flex
    assert_equal 10, flex.minutes
    assert_equal 2, flex.hours
    @user.reload
    assert_equal '2:10', @user.flex_time
  end

  def test_running_total_minutes
    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 10,
                               :hours => 0,
                               :positive => true)
    assert_valid flex
    assert_equal 10, flex.minutes
    assert_equal 0, flex.hours
    assert_equal 10, flex.total_minutes
    assert_equal 0, flex.total_hours
    @user.reload
    assert_equal '0:10', @user.flex_time

    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 5,
                               :hours => 0,
                               :positive => true)
    assert_valid flex
    assert_equal 5, flex.minutes
    assert_equal 0, flex.hours
    assert_equal 15, flex.total_minutes
    assert_equal 0, flex.total_hours
    @user.reload
    assert_equal '0:15', @user.flex_time

    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 50,
                               :hours => 0,
                               :positive => true)
    assert_valid flex
    assert_equal 50, flex.minutes
    assert_equal 0, flex.hours
    assert_equal 5, flex.total_minutes
    assert_equal 1, flex.total_hours
    @user.reload
    assert_equal '1:05', @user.flex_time
  end

  def test_running_total_hours
    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 0,
                               :hours => 1,
                               :positive => true)
    assert_valid flex
    assert_equal 0, flex.minutes
    assert_equal 1, flex.hours
    assert_equal 0, flex.total_minutes
    assert_equal 1, flex.total_hours
    @user.reload
    assert_equal '1:00', @user.flex_time

    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 0,
                               :hours => 2,
                               :positive => true)
    assert_valid flex
    assert_equal 0, flex.minutes
    assert_equal 2, flex.hours
    assert_equal 0, flex.total_minutes
    assert_equal 3, flex.total_hours
    @user.reload
    assert_equal '3:00', @user.flex_time

    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 0,
                               :hours => 4,
                               :positive => true)
    assert_valid flex
    assert_equal 0, flex.minutes
    assert_equal 4, flex.hours
    assert_equal 0, flex.total_minutes
    assert_equal 7, flex.total_hours
    @user.reload
    assert_equal '7:00', @user.flex_time
  end

  def test_running_total_hours_and_minutes
    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 5,
                               :hours => 1,
                               :positive => true)
    assert_valid flex
    assert_equal 5, flex.minutes
    assert_equal 1, flex.hours
    assert_equal 5, flex.total_minutes
    assert_equal 1, flex.total_hours
    @user.reload
    assert_equal '1:05', @user.flex_time

    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 50,
                               :hours => 0,
                               :positive => true)
    assert_valid flex
    assert_equal 50, flex.minutes
    assert_equal 0, flex.hours
    assert_equal 55, flex.total_minutes
    assert_equal 1, flex.total_hours
    @user.reload
    assert_equal '1:55', @user.flex_time

    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 20,
                               :hours => 1,
                               :positive => true)
    assert_valid flex
    assert_equal 20, flex.minutes
    assert_equal 1, flex.hours
    assert_equal 15, flex.total_minutes
    assert_equal 3, flex.total_hours
    @user.reload
    assert_equal '3:15', @user.flex_time
  end

  def test_negative_running_total_hours_and_minutes
    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 5,
                               :hours => 1,
                               :positive => false)
    assert_valid flex
    assert_equal -5, flex.minutes
    assert_equal -1, flex.hours
    assert_equal -5, flex.total_minutes
    assert_equal -1, flex.total_hours
    @user.reload
    assert_equal '-1:05', @user.flex_time

    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 50,
                               :hours => 0,
                               :positive => false)
    assert_valid flex
    assert_equal -50, flex.minutes
    assert_equal -0, flex.hours
    assert_equal -55, flex.total_minutes
    assert_equal -1, flex.total_hours
    @user.reload
    assert_equal '-1:55', @user.flex_time

    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 20,
                               :hours => 1,
                               :positive => false)
    assert_valid flex
    assert_equal -20, flex.minutes
    assert_equal -1, flex.hours
    assert_equal -15, flex.total_minutes
    assert_equal -3, flex.total_hours
    @user.reload
    assert_equal '-3:15', @user.flex_time
  end

  def test_positive_negative_running_total_hours_and_minutes
    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 5,
                               :hours => 0,
                               :positive => false)
    assert_valid flex
    assert_equal -5, flex.minutes
    assert_equal 0, flex.hours
    assert_equal -5, flex.total_minutes
    assert_equal 0, flex.total_hours
    @user.reload
    assert_equal '-0:05', @user.flex_time

    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 20,
                               :hours => 0,
                               :positive => true)
    assert_valid flex
    assert_equal 20, flex.minutes
    assert_equal 0, flex.hours
    assert_equal 15, flex.total_minutes
    assert_equal 0, flex.total_hours
    @user.reload
    assert_equal '0:15', @user.flex_time

    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 20,
                               :hours => 1,
                               :positive => false)
    assert_valid flex
    assert_equal -20, flex.minutes
    assert_equal -1, flex.hours
    assert_equal -5, flex.total_minutes
    assert_equal -1, flex.total_hours
    @user.reload
    assert_equal '-1:05', @user.flex_time

    flex = @user.flexes.create(:comment => 'test flex',
                               :minutes => 55,
                               :hours => 2,
                               :positive => true)
    assert_valid flex
    assert_equal 55, flex.minutes
    assert_equal 2, flex.hours
    assert_equal 50, flex.total_minutes
    assert_equal 1, flex.total_hours
    @user.reload
    assert_equal '1:50', @user.flex_time
  end

  def test_discard_and_cascade
    flex1 = @user.flexes.create(:comment => 'test flex',
                                :minutes => 10,
                                :hours => 0,
                                :positive => true)
    assert_valid flex1
    @user.reload
    assert_equal '0:10', @user.flex_time
    assert_equal 0, flex1.total_hours
    assert_equal 10, flex1.total_minutes

    flex2 = @user.flexes.create(:comment => 'test flex',
                                :minutes => 5,
                                :hours => 0,
                                :positive => true)
    assert_valid flex2
    @user.reload
    assert_equal '0:15', @user.flex_time

    flex3 = @user.flexes.create(:comment => 'test flex',
                                :minutes => 50,
                                :hours => 0,
                                :positive => true)
    assert_valid flex3
    @user.reload
    assert_equal '1:05', @user.flex_time

    flex1.update_attribute :discarded, true
    @user.reload

    [flex1,flex2,flex3].each{|x| x.reload}
    assert_equal 0, flex1.total_hours
    assert_equal 10, flex1.total_minutes
    assert_equal 0, flex2.total_hours
    assert_equal 5, flex2.total_minutes
    assert_equal 0, flex3.total_hours
    assert_equal 55, flex3.total_minutes
    assert_equal '0:55', @user.flex_time
  end

  def test_minutes_then_hours
    flex1 = @user.flexes.create(:comment => 'test flex',
                                :minutes => 5,
                                :hours => 0,
                                :positive => true)
    flex2 = @user.flexes.create(:comment => 'test flex',
                                :minutes => 0,
                                :hours => 1,
                                :positive => false)
    @user.reload

    assert_equal 0, flex1.hours
    assert_equal 5, flex1.minutes
    assert_equal 0, flex1.total_hours
    assert_equal 5, flex1.total_minutes

    assert_equal -1, flex2.hours
    assert_equal 0, flex2.minutes
    assert_equal 0, flex2.total_hours
    assert_equal -55, flex2.total_minutes


    assert_equal '-0:55', @user.flex_time
  end

  def test_negative_input
    flex = @user.flexes.create(:comment => 'test flex',
                                :minutes => 0,
                                :hours => -1,
                                :positive => true)
    assert_valid flex
    assert_equal -1, flex.hours
    assert_equal false, flex.positive
  end

  def test_double_negative_input
    flex = @user.flexes.create(:comment => 'test flex',
                                :minutes => 0,
                                :hours => -1,
                                :positive => false)
    assert_not_valid flex
    assert flex.errors[:base].include?('You can not provide a double-negative time.')
  end

  def test_negative_minutes_positive_hours
    flex = @user.flexes.create(:comment => 'test flex',
                                :minutes => -60,
                                :hours => 1,
                                :positive => true)
    assert_equal 0, flex.minutes
    assert_equal 0, flex.hours
  end

  def test_repeated_discard_and_restore_positive
    flex = @user.flexes.create(:comment => 'test flex',
                                :minutes => 60,
                                :hours => 0,
                                :positive => true)
    assert_equal '1:00', @user.flex_time
    @user.flexes.create(:comment => 'test flex',
                        :minutes => 20,
                        :hours => 0,
                        :positive => true)
    assert_equal '1:20', @user.flex_time
    flex.update_attribute :discarded, true
    assert_equal '0:20', @user.flex_time
    flex.update_attribute :discarded, false
    assert_equal '1:20', @user.flex_time
    flex.update_attribute :discarded, true
    assert_equal '0:20', @user.flex_time
    flex.update_attribute :discarded, false
    assert_equal '1:20', @user.flex_time
  end

  def test_repeated_discard_and_restore_negative
    flex1 = @user.flexes.create(:comment => 'test flex',
                                :minutes => 10,
                                :hours => 0,
                                :positive => false)
    assert_equal '-0:10', @user.flex_time
    flex2 = @user.flexes.create(:comment => 'test flex',
                                :minutes => 10,
                                :hours => 0,
                                :positive => true)

    assert_equal 0, flex2.hours
    assert_equal 10, flex2.minutes
    assert_equal 0, flex1.hours
    assert_equal -10, flex1.minutes

    #flex1.update_attribute :discarded, true
    flex1.save
    assert_equal 0, flex2.hours
    assert_equal 10, flex2.minutes
    assert_equal 0, flex1.hours
    assert_equal -10, flex1.minutes

    #flex1.update_attribute :discarded, false
    #flex1.update_attribute :discarded, true
    #flex1.update_attribute :discarded, false
  end


  # INVALID tests
  def test_invalid_no_input
    flex = Flex.new
    assert_not_valid flex
    assert flex.errors[:base]
    assert flex.errors[:base].include?('Hours or minutes must be more than zero. (Flexing your time by nothing is leaving it be)')
    assert flex.errors[:comment]
    assert flex.errors[:user]
  end


end
