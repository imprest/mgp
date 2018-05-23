defmodule Mgp.AccountsTest do
  use Mgp.DataCase

  alias Mgp.Accounts

  describe "pdcs" do
    alias Mgp.Accounts.Pdc

    @valid_attrs %{amount: "some amount", cheque: "some cheque", date: ~D[2010-04-17], lmd: ~D[2010-04-17], lmt: ~T[14:00:00.000000], lmu: "some lmu"}
    @update_attrs %{amount: "some updated amount", cheque: "some updated cheque", date: ~D[2011-05-18], lmd: ~D[2011-05-18], lmt: ~T[15:01:01.000000], lmu: "some updated lmu"}
    @invalid_attrs %{amount: nil, cheque: nil, date: nil, lmd: nil, lmt: nil, lmu: nil}

    def pdc_fixture(attrs \\ %{}) do
      {:ok, pdc} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_pdc()

      pdc
    end

    test "list_pdcs/0 returns all pdcs" do
      pdc = pdc_fixture()
      assert Accounts.list_pdcs() == [pdc]
    end

    test "get_pdc!/1 returns the pdc with given id" do
      pdc = pdc_fixture()
      assert Accounts.get_pdc!(pdc.id) == pdc
    end

    test "create_pdc/1 with valid data creates a pdc" do
      assert {:ok, %Pdc{} = pdc} = Accounts.create_pdc(@valid_attrs)
      assert pdc.amount == "some amount"
      assert pdc.cheque == "some cheque"
      assert pdc.date == ~D[2010-04-17]
      assert pdc.lmd == ~D[2010-04-17]
      assert pdc.lmt == ~T[14:00:00.000000]
      assert pdc.lmu == "some lmu"
    end

    test "create_pdc/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_pdc(@invalid_attrs)
    end

    test "update_pdc/2 with valid data updates the pdc" do
      pdc = pdc_fixture()
      assert {:ok, pdc} = Accounts.update_pdc(pdc, @update_attrs)
      assert %Pdc{} = pdc
      assert pdc.amount == "some updated amount"
      assert pdc.cheque == "some updated cheque"
      assert pdc.date == ~D[2011-05-18]
      assert pdc.lmd == ~D[2011-05-18]
      assert pdc.lmt == ~T[15:01:01.000000]
      assert pdc.lmu == "some updated lmu"
    end

    test "update_pdc/2 with invalid data returns error changeset" do
      pdc = pdc_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_pdc(pdc, @invalid_attrs)
      assert pdc == Accounts.get_pdc!(pdc.id)
    end

    test "delete_pdc/1 deletes the pdc" do
      pdc = pdc_fixture()
      assert {:ok, %Pdc{}} = Accounts.delete_pdc(pdc)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_pdc!(pdc.id) end
    end

    test "change_pdc/1 returns a pdc changeset" do
      pdc = pdc_fixture()
      assert %Ecto.Changeset{} = Accounts.change_pdc(pdc)
    end
  end

  describe "postings" do
    alias Mgp.Accounts.Posting

    @valid_attrs %{amount: "some amount", date: ~D[2010-04-17], description: "some description", lmd: ~D[2010-04-17], lmt: ~T[14:00:00.000000], lmu: "some lmu"}
    @update_attrs %{amount: "some updated amount", date: ~D[2011-05-18], description: "some updated description", lmd: ~D[2011-05-18], lmt: ~T[15:01:01.000000], lmu: "some updated lmu"}
    @invalid_attrs %{amount: nil, date: nil, description: nil, lmd: nil, lmt: nil, lmu: nil}

    def posting_fixture(attrs \\ %{}) do
      {:ok, posting} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_posting()

      posting
    end

    test "list_postings/0 returns all postings" do
      posting = posting_fixture()
      assert Accounts.list_postings() == [posting]
    end

    test "get_posting!/1 returns the posting with given id" do
      posting = posting_fixture()
      assert Accounts.get_posting!(posting.id) == posting
    end

    test "create_posting/1 with valid data creates a posting" do
      assert {:ok, %Posting{} = posting} = Accounts.create_posting(@valid_attrs)
      assert posting.amount == "some amount"
      assert posting.date == ~D[2010-04-17]
      assert posting.description == "some description"
      assert posting.lmd == ~D[2010-04-17]
      assert posting.lmt == ~T[14:00:00.000000]
      assert posting.lmu == "some lmu"
    end

    test "create_posting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_posting(@invalid_attrs)
    end

    test "update_posting/2 with valid data updates the posting" do
      posting = posting_fixture()
      assert {:ok, posting} = Accounts.update_posting(posting, @update_attrs)
      assert %Posting{} = posting
      assert posting.amount == "some updated amount"
      assert posting.date == ~D[2011-05-18]
      assert posting.description == "some updated description"
      assert posting.lmd == ~D[2011-05-18]
      assert posting.lmt == ~T[15:01:01.000000]
      assert posting.lmu == "some updated lmu"
    end

    test "update_posting/2 with invalid data returns error changeset" do
      posting = posting_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_posting(posting, @invalid_attrs)
      assert posting == Accounts.get_posting!(posting.id)
    end

    test "delete_posting/1 deletes the posting" do
      posting = posting_fixture()
      assert {:ok, %Posting{}} = Accounts.delete_posting(posting)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_posting!(posting.id) end
    end

    test "change_posting/1 returns a posting changeset" do
      posting = posting_fixture()
      assert %Ecto.Changeset{} = Accounts.change_posting(posting)
    end
  end

  describe "op_balances" do
    alias Mgp.Accounts.OpBalance

    @valid_attrs %{op_bal: "120.5", year: 42}
    @update_attrs %{op_bal: "456.7", year: 43}
    @invalid_attrs %{op_bal: nil, year: nil}

    def op_balance_fixture(attrs \\ %{}) do
      {:ok, op_balance} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_op_balance()

      op_balance
    end

    test "list_op_balances/0 returns all op_balances" do
      op_balance = op_balance_fixture()
      assert Accounts.list_op_balances() == [op_balance]
    end

    test "get_op_balance!/1 returns the op_balance with given id" do
      op_balance = op_balance_fixture()
      assert Accounts.get_op_balance!(op_balance.id) == op_balance
    end

    test "create_op_balance/1 with valid data creates a op_balance" do
      assert {:ok, %OpBalance{} = op_balance} = Accounts.create_op_balance(@valid_attrs)
      assert op_balance.op_bal == Decimal.new("120.5")
      assert op_balance.year == 42
    end

    test "create_op_balance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_op_balance(@invalid_attrs)
    end

    test "update_op_balance/2 with valid data updates the op_balance" do
      op_balance = op_balance_fixture()
      assert {:ok, op_balance} = Accounts.update_op_balance(op_balance, @update_attrs)
      assert %OpBalance{} = op_balance
      assert op_balance.op_bal == Decimal.new("456.7")
      assert op_balance.year == 43
    end

    test "update_op_balance/2 with invalid data returns error changeset" do
      op_balance = op_balance_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_op_balance(op_balance, @invalid_attrs)
      assert op_balance == Accounts.get_op_balance!(op_balance.id)
    end

    test "delete_op_balance/1 deletes the op_balance" do
      op_balance = op_balance_fixture()
      assert {:ok, %OpBalance{}} = Accounts.delete_op_balance(op_balance)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_op_balance!(op_balance.id) end
    end

    test "change_op_balance/1 returns a op_balance changeset" do
      op_balance = op_balance_fixture()
      assert %Ecto.Changeset{} = Accounts.change_op_balance(op_balance)
    end
  end

  describe "users" do
    alias Mgp.Accounts.User

    @valid_attrs %{is_admin: true, password: "some password", role: "some role", salt: "some salt", username: "some username"}
    @update_attrs %{is_admin: false, password: "some updated password", role: "some updated role", salt: "some updated salt", username: "some updated username"}
    @invalid_attrs %{is_admin: nil, password: nil, role: nil, salt: nil, username: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.is_admin == true
      assert user.password == "some password"
      assert user.role == "some role"
      assert user.salt == "some salt"
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.is_admin == false
      assert user.password == "some updated password"
      assert user.role == "some updated role"
      assert user.salt == "some updated salt"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
