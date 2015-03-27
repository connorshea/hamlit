require 'hamlit/filter'

# Haml-spec specifies attribute order inspite of an original order.
# Because temple's parser should return a result as original as possible,
# ordering of it is delegated to this filter.
module Hamlit
  class AttributeSorter < Hamlit::Filter
    def on_haml_attrs(*attrs)
      attrs = join_ids(attrs)
      attrs = combine_classes(attrs)
      attrs = pull_class_first(attrs)
      [:html, :attrs, *attrs]
    end

    private

    def pull_class_first(attrs)
      class_attrs = filter_attrs(attrs, 'class')
      combine_classes(class_attrs) + (attrs - class_attrs)
    end

    def combine_classes(attrs)
      class_attrs = filter_attrs(attrs, 'class')
      return attrs if class_attrs.length <= 1

      values = class_attrs.map(&:last).sort_by(&:last)
      [[:html, :attr, 'class', [:multi, *insert_static(values, ' ')]]] + (attrs - class_attrs)
    end

    def join_ids(attrs)
      id_attrs = filter_attrs(attrs, 'id')
      return attrs if id_attrs.length <= 1

      values = attrs.map(&:last)
      [[:html, :attr, 'id', [:multi, *insert_static(values, '_')]]] + (attrs - id_attrs)
    end

    def filter_attrs(attrs, target)
      class_attrs = attrs.select do |html, attr, name, content|
        name == target
      end
    end

    def insert_static(array, str)
      result = []
      array.each_with_index do |value, index|
        result << [:static, str] if index > 0
        result << value
      end
      result
    end
  end
end