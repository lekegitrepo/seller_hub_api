require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create :user }
  # before { user }
  # subject { user }

  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }

  it { should be_valid }
end