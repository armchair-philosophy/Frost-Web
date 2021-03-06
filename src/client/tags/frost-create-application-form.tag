<frost-create-application-form>
	<h4>連携アプリケーションを作成する</h4><!-- Create an application -->
	<div show={ isShowModal }>
		<form onsubmit={ submit }>
			<label for='application-name'>連携アプリケーション名 *</label><!-- Application name -->
			<input ref='name' class='name-box' type='text' id='application-name' name='name' placeholder='example: Frost Client' style='width: 100%' maxlength='32' required />
			<label for='application-description'>説明</label><!-- Description -->
			<textarea ref='description' class='description-box' id='application-description' name='description' rows='3' style='width: 100%' maxlength='256' />
			<fieldset class='permissions'>
				<label>権限</label><!-- Permissions -->
				<label for='permissions-userRead'>
					<input type='checkbox' id='permissions-userRead' name='permissions' value='userRead'>userRead - ユーザーに関する読み取り</input><!-- userRead - Reading about users -->
				</label>
				<label for='permissions-userWrite'>
					<input type='checkbox' id='permissions-userWrite' name='permissions' value='userWrite'>userWrite - ユーザーに関する書き換え</input><!-- userWrite - Writing about users -->
				</label>
				<label for='permissions-postRead'>
					<input type='checkbox' id='permissions-postRead' name='permissions' value='postRead'>postRead - ポストに関する読み取り</input><!-- postRead - Reading about posts -->
				</label>
				<label for='permissions-postWrite'>
					<input type='checkbox' id='permissions-postWrite' name='permissions' value='postWrite'>postWrite - ポストに関する書き換え</input><!-- postWrite - Writing about posts -->
				</label>
				<label for='permissions-accountRead'>
					<input type='checkbox' id='permissions-accountRead' name='permissions' value='accountRead'>accountRead - アカウントに関する読み取り</input><!-- accountRead - Reading about your account -->
				</label>
				<label for='permissions-accountWrite'>
					<input type='checkbox' id='permissions-accountWrite' name='permissions' value='accountWrite'>accountWrite - アカウントに関する書き換え</input><!-- accountWrite - Writing about your account -->
				</label>
				<label for='permissions-application'>
					<input type='checkbox' id='permissions-application' name='permissions' value='application'>application - 所持する連携アプリケーションに関する操作</input><!-- application - Accessing about your applications -->
				</label>
			</fieldset>
			<div id='recaptcha-create-application'></div>
			<button class='button-primary'>作成する</button><!-- Create -->
		</form>
	</div>
	<button class='button orange-button' onclick={ showModal }>{ isShowModal ? '折りたたむ -' : '展開する +' }</button>

	<script>
		const StreamingRest = require('../helpers/StreamingRest');
		this.isShowModal = false;

		this.showModal = () => {
			this.isShowModal = !this.isShowModal;
		};

		this.on('mount', () => {
			this.submit = (e) => {
				e.preventDefault();

				const permissions = [];
				for (let permission of document.querySelectorAll('frost-create-application-form .permissions *')) {
					if (permission.checked) {
						permissions.push(permission.value);
					}
				}

				(async () => {
					const streamingRest = new StreamingRest(this.webSocket);
					const rest = await streamingRest.requestAsync('post', '/applications', {
						body: {
							name: this.refs.name.value,
							description: this.refs.description.value,
							permissions: permissions,
							recaptchaToken: grecaptcha.getResponse()
						}
					});
					if (rest.response.application != null) {
						this.central.trigger('add-application', {application: rest.response.application});
						alert('created application.');
					}
					else {
						alert(`api error: failed to create application. ${rest.response.message}`);
					}
				})().catch(err => {
					console.error(err);
				});
			};

			grecaptcha.render('recaptcha-create-application', {
				sitekey: this.siteKey
			});
		});

		this.on('unmount', () => {
			// reCAPTCHAから生成される要素を削除
			document.querySelector('.g-recaptcha-bubble-arrow').parentNode.remove();
		});
	</script>
</frost-create-application-form>
