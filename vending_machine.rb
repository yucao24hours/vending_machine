require_relative "./drink"
require "pry"

class VendingMachine
  ACCEPTABLE_MONEY = [10, 50, 100, 500, 1_000]

  # amount: 売上
  # summary: 投入合計金額
  # stocks: 在庫一覧
  attr_reader :summary, :stocks, :amount

  def initialize(drinks)
    @stocks = []

    add_stocks(drinks)

    # 売上累計金額
    @amount = 0
    # 投入累計金額
    @summary = 0
  end

  def stocks_find_by_name(drink_name)
    @stocks.group_by{|item| item.name }[drink_name] || []
  end

  def input(money)
    if ACCEPTABLE_MONEY.include?(money)
      @summary += money
    else
      return_change(money)
    end
  end

  def refund
    change = @summary
    @summary = 0

    change
  end

  def add_stocks(drinks)
    @stocks.concat(drinks)
  end

  def sell(drink_name)
    # XXX 二段階で処理してるのでなんか微妙だけど、いい方法が他にあるのだろうか
    # XXX 在庫がなかったときの処理はまだ書いていない
    if can_buy?(drink_name)
      index = @stocks.find_index{|stock| stock.name == drink_name }
      sold = @stocks.delete_at(index)
      @amount += sold.price
      @summary -= sold.price

      refund
    end
  end

  def buyable_drinks
    # 在庫があり、かつ投入金額 summary がその商品の価格と同じか上回っていれば出す
    @stocks.each_with_object([]) do |stock, memo|
      # XXX include? で同じ飲み物に対して同じ処理を二度以上しないようにして急場をしのいでいるが、
      #     本来なら、購入可能かどうかにかかわらず在庫一覧は用意したほうがいい。
      next if memo.include?(stock.name)

      # NOTE: @stocks にあるのは在庫 1 つ以上ある商品なので、在庫の有無に関する
      #       条件文は明示的に書く必要はない。
      memo << stock.name if @summary >= stock.price
    end
  end

  private

  def return_change(money)
    return money
  end

  def can_buy?(drink_name)
    drink = @stocks.detect{|stock| stock.name == drink_name }
    return false unless drink

    (@summary >= drink.price) && (stocks_find_by_name(drink.name).count > 0)
  end
end
