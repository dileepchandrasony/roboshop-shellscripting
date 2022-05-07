frontend:
	@bash components/frontend.sh

mongodb:
	@bash components/mongodb.sh

catalogue:
	@bash components/catalogue.sh

redis:
	@bash components/redis.sh

cart:
	@bash components/cart.sh

dispatch:
	@bash components/dispatch.sh

mysql:
	@bash components/mysql.sh

payment:
	@bash components/payment.sh

rabbitmq:
	@bash components/rabbitmq.sh

shipping:
	@bash components/shipping.sh

user:
	@bash components/user.sh
