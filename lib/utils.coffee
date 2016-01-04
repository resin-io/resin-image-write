###
Copyright 2016 Resin.io

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###

Promise = require('bluebird')
fs = Promise.promisifyAll(require('fs'))

###*
# @summary Erase MBR from a device
# @function
# @protected
#
# @description
# Write 512 null bytes at the beginning of a device
#
# @param {String} device - device
# @returns {Promise}
#
# @example
# utils.eraseMBR('/dev/disk2')
###
exports.eraseMBR = (device) ->
	bufferSize = 512
	buffer = new Buffer(bufferSize)
	buffer.fill(0)

	fs.openAsync(device, 'rs+').then (fd) ->
		fs.writeAsync(fd, buffer, 0, bufferSize, 0).spread (bytesWritten) ->
			if bytesWritten isnt bufferSize
				throw new Error("Bytes written: #{bytesWritten}, expected #{bufferSize}")
			fs.closeAsync(fd)

###*
# @summary Get raw device file
# @function
# @protected
#
# @description
# This function only performs manipulations for OS X disks.
# See http://superuser.com/questions/631592/why-is-dev-rdisk-about-20-times-faster-than-dev-disk-in-mac-os-x
#
# @param {String} device - device
# @returns {String} raw device
#
# @example
# rawDevice = utils.getRawDevice('/dev/disk2')
###
exports.getRawDevice = (device) ->
	match = device.match(/\/dev\/disk(\d+)/)
	return device if not match?
	return "/dev/rdisk#{match[1]}"
