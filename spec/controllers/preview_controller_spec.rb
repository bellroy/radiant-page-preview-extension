require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class TestPage < Page
end

describe PreviewController do
  scenario :users
  before(:each) do
    login_as :admin
  end

  it 'should construct the page and process it' do
    controller.should_receive(:construct_page).and_return(mock('page', :process => true))
    post :show
  end
  
  describe 'construct page' do
    before(:all) do
      PreviewController.class_eval { public :construct_page }
    end
    before(:each) do
      controller.stub!(:params).and_return({:page => {:class_name => 'page'}.with_indifferent_access}.with_indifferent_access)
    end
    describe 'new child' do
      before do
        Page.stub!(:find).and_return Page.new(:id => 1)
        request.stub!(:referer).and_return('/admin/pages/1/child/new')
        controller.stub!(:request).and_return(request)
      end
      it 'should get the referrer' do
        request.should_receive(:referer).at_least(:once)
        controller.construct_page
      end
      it 'should retrieve the class_name from the params' do
        controller.params[:page].should_receive(:[]).with(:class_name).and_return 'page'
        controller.construct_page
      end
      it 'should create a new page' do
        controller.params[:page].stub!(:[]).with(:class_name).and_return 'test_page'
        controller.construct_page.class.should == TestPage
      end
      it 'should set get the parent from the referer' do
        request.stub!(:referer).and_return('/admin/pages/100/child/new')
        Page.should_receive(:find).with('100')
        controller.construct_page
      end
      it 'should assign the parent from the referer to the page' do
        parent = mock_model(Page)
        Page.stub!(:find).and_return parent
        controller.construct_page.parent.should == parent
      end
    end
  end
  
end