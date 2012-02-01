require 'test_helper'

class StorylinesControllerTest < ActionController::TestCase
  setup do
    @storyline = storylines(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:storylines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create storyline" do
    assert_difference('Storyline.count') do
      post :create, storyline: @storyline.attributes
    end

    assert_redirected_to storyline_path(assigns(:storyline))
  end

  test "should show storyline" do
    get :show, id: @storyline
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @storyline
    assert_response :success
  end

  test "should update storyline" do
    put :update, id: @storyline, storyline: @storyline.attributes
    assert_redirected_to storyline_path(assigns(:storyline))
  end

  test "should destroy storyline" do
    assert_difference('Storyline.count', -1) do
      delete :destroy, id: @storyline
    end

    assert_redirected_to storylines_path
  end
end
