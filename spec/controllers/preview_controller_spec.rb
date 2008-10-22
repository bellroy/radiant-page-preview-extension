require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class TestPage < Page
end

describe PreviewController do
  scenario :users, :home_page
  before(:each) do
    login_as :admin
  end

  describe 'show' do
    it 'should construct the page and process it' do
      controller.should_receive(:construct_page).and_return(mock('page', :process => true))
      post :show
    end

    it 'should test that it does not modify page'
    it 'should test that it renders exceptions'
  end
  
  describe 'construct page' do
    before(:all) do
      PreviewController.class_eval { public :construct_page }
    end
    before(:each) do
      controller.stub!(:params).
        and_return({:page => {:class_name => 'page'}.with_indifferent_access}.with_indifferent_access)
      @page = Page.new(:id => 1)
      controller.stub!(:request).and_return(request)
    end
    describe 'any page', :shared => true do
      it 'should retrieve parts from params' do
        controller.params[:part] = []
        controller.construct_page
        controller.construct_page.parts.should be_empty
      end
      it 'should contain parts created' do
        controller.params[:part] = {'0' => {:name=> 'new part'}}

        controller.construct_page.parts.should_not be_empty
        controller.construct_page.parts.first.name.should == 'new part'
      end
      it 'should not contain remove deleted parts' do
        @page.parts.build :name => 'delete me'

        controller.construct_page.parts.should be_empty 
      end
    end
    
    describe 'new child' do
      before do
        Page.stub!(:find).and_return @page
        request.stub!(:referer).and_return('/admin/pages/1/child/new')
      end
      it_should_behave_like "any page"
      it 'should not save any changes' do
        page_count = Page.count
        controller.construct_page
        Page.count.should == page_count
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
    describe 'edit existing page' do
      before do
        request.stub!(:referer).and_return('/admin/pages/edit/1')
        controller.params[:page][:class_name] = "Page"
        @page = Page.find(:first)
        Page.stub!(:find).and_return @page
      end
      it_should_behave_like "any page"
      it 'should not save any changes' #TODO: Test this somehow
      it 'should have the original pages children' do
        #TODO: Make this text more explicitly test children
        controller.construct_page.children.should == @page.children
      end
      it 'should have the original pages parent' do
        #TODO: Make this text more explicitly test parent
        controller.construct_page.parent.should == @page.parent
      end
      it 'should change page class if it has changed' do
        controller.params[:page][:class_name] = "TestPage"  
        controller.construct_page.class.should == TestPage
      end
      it 'should have params attributes, not the existing page attributes' do
        @page.title = 'foo'
        controller.params[:page][:title] = 'bar'
        controller.construct_page.title.should == 'bar'
      end
    end
  end
end
