module CitationsHelper
  def previous_and_next_ids(id)
    ids = {}
    prev = Citation.first(:conditions=>["id < ?", id], :order=>"id DESC")
    nxt = Citation.first(:conditions=>["id > ?", id], :order=>"id")
    ids[:prev] = prev if prev
    ids[:next] = nxt if nxt
    ids
  end
end