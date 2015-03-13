/* This file is part of RTags.

RTags is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

RTags is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with RTags.  If not, see <http://www.gnu.org/licenses/>. */

#ifndef RTagsLogOutput_h
#define RTagsLogOutput_h

#include <rct/String.h>
#include <rct/Log.h>
#include <rct/Connection.h>

class RTagsLogOutput : public LogOutput
{
public:
    RTagsLogOutput(int level, unsigned int flags)
        : LogOutput(level), mFlags(flags)
    {
    }

    enum Flag {
        None = 0x0,
        ElispList = 0x1
    };

    unsigned int flags() const { return mFlags; }

    virtual bool testLog(int level) const
    {
        if (logLevel() < 0 || level < 0)
            return level == logLevel();
        return LogOutput::testLog(level);
    }
private:
    const unsigned int mFlags;
};

class RTagsConnectionLogOutput : public RTagsLogOutput
{
public:
    RTagsConnectionLogOutput(const std::shared_ptr<Connection> &conn, int level, unsigned int flags)
        : RTagsLogOutput(level, flags), mConnection(conn)
    {
        conn->disconnected().connect(std::bind(&RTagsConnectionLogOutput::remove, this));
    }
    ~RTagsConnectionLogOutput()
    {
        printf("[%s:%d]: ~RTagsConnectionLogOutput()\n", __FILE__, __LINE__); fflush(stdout);
    }

    virtual void log(const char *msg, int len)
    {
        std::shared_ptr<EventLoop> main = EventLoop::mainEventLoop();
        if (EventLoop::eventLoop() == main) {
            mConnection->write(String(msg, len));
        } else {
            EventLoop::mainEventLoop()->callLaterMove(std::bind((bool(Connection::*)(Message&&))&Connection::send, mConnection, std::placeholders::_1),
                                                      ResponseMessage(String(msg, len)));
        }
    }
private:
    std::shared_ptr<Connection> mConnection;
};

#endif
