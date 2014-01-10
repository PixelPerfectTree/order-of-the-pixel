module JsonHelpers

	def parsed_params
		# debugger
		if request.get? || request.delete?
			parsed = params
		else
			parsed = JSON.parse(request.body.read, :quirks_mode => true)
		end

		parsed = {} unless parsed.is_a?(Hash)

		return parsed
	end
end